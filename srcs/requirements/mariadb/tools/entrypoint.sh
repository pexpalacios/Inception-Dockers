#!/bin/bash
set -e

MYSQL_DATADIR=/var/lib/mysql
MYSQL_ROOT_PASSWORD_FILE=/run/secrets/db_root_password
MYSQL_PASSWORD_FILE=/run/secrets/db_password

if [ ! -d "$MYSQL_DATADIR/mysql" ]; then
	echo "Initializing MariaDB data directory..."
	mkdir -p "$MYSQL_DATADIR"
	chown -R mysql:mysql "$MYSQL_DATADIR"

	mysqld --initialize-insecure --user=mysql --datadir="$MYSQL_DATADIR"

	# Start temporary server
	mysqld_safe --datadir="$MYSQL_DATADIR" &
	pid="$!"

	for i in {30..0}; do
		if mysqladmin ping --silent; then
			break
		fi
		sleep 1
	done

	# Set root password from Docker secret if present
	if [ -f "$MYSQL_ROOT_PASSWORD_FILE" ]; then
		ROOT_PASS=$(cat "$MYSQL_ROOT_PASSWORD_FILE" | tr -d '\n')
		echo "Setting MariaDB root password from secret..."
		mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$ROOT_PASS'; FLUSH PRIVILEGES;"
	fi

	# Create wordpress database and user if secret present
	if [ -f "$MYSQL_PASSWORD_FILE" ]; then
		WP_PASS=$(cat "$MYSQL_PASSWORD_FILE" | tr -d '\n')
		WP_DB=${WP_DB:-wordpress}
		WP_USER=${WP_USER:-wp_user}
		echo "Creating WordPress database and user..."
		mysql -e "CREATE DATABASE IF NOT EXISTS \\`$WP_DB\\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
		mysql -e "CREATE USER IF NOT EXISTS '$WP_USER'@'%' IDENTIFIED BY '$WP_PASS';"
		mysql -e "GRANT ALL PRIVILEGES ON \\`$WP_DB\\`.* TO '$WP_USER'@'%'; FLUSH PRIVILEGES;"
	fi

	# Stop temporary server
	mysqladmin shutdown || kill "$pid"
	wait "$pid" 2>/dev/null || true
	echo "MariaDB initialization complete."
fi

echo "Starting MariaDB..."
exec mysqld --user=mysql --datadir="$MYSQL_DATADIR"
