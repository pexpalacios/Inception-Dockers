#!/bin/bash
set -e

echo "Starting MariaDB..."

#Init MySQL data dir if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initializing data directory for MySQL..."
	mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi


#Start the server
echo "Starting temp MariadDB server for setup..."
until mysqladmin --socket=/run/mysql/mysql.sock ping > /dev/null 2>&1; do
	sleep 1
done
echo "Temporary server ready"

MYSQL_DATADIR=/var/lib/mysql
MYSQL_ROOT_PASSWORD_FILE=/run/secrets/db_root_password
MYSQL_PASSWORD_FILE=/run/secrets/db_password

#Created database and users
echo "Setting up MySQL..."
mysql --socket=/run/mysqld/mysqld.sock -u root << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

#Shutdown temporary server
echo "Shutting down temporary server..."
mysqladmin --socket=/run/mysql/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
wait "$pid" || true

#Start the real MariaDB server
echo "Starting MariaDB..."
exec mysqld --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock

########## OVA 4 version
#!/bin/bash
# set -e

# MYSQL_DATADIR=/var/lib/mysql
# MYSQL_ROOT_PASSWORD_FILE=/run/secrets/db_root_password
# MYSQL_PASSWORD_FILE=/run/secrets/db_password

# if [ ! -d "$MYSQL_DATADIR/mysql" ]; then
# 	echo "Initializing MariaDB data directory..."
# 	mkdir -p "$MYSQL_DATADIR"
# 	chown -R mysql:mysql "$MYSQL_DATADIR"

# 	mysql_install_db --user=mysql --datadir="$MYSQL_DATADIR" --skip-test-db

# 	# Start temporary server
# 	mysqld_safe --datadir="$MYSQL_DATADIR" &
# 	pid="$!"

# 	for i in {30..0}; do
# 		if mysqladmin ping --silent; then
# 			break
# 		fi
# 		sleep 1
# 	done

# 	# Set root password from Docker secret if present
# 	if [ -f "$MYSQL_ROOT_PASSWORD_FILE" ]; then
# 		echo "Setting MariaDB root password from secret..."
# 		MYSQL_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
# 		mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD'; FLUSH PRIVILEGES;"
# 	fi

# 	# Create wordpress database and user if secret present
# 	if [ -f "$MYSQL_PASSWORD_FILE" ]; then
# 		echo "Creating WordPress database and user..."
# 		MYSQL_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")
# 		mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
# 		mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
# 		mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%'; FLUSH PRIVILEGES;"
# 	fi

# 	# Stop temporary server
# 	mysqladmin -uroot -p"$MYSQL_ROOT_PASSWORD" shutdown || kill "$pid"
# 	wait "$pid" 2>/dev/null || true
# 	echo "MariaDB initialization complete."
# fi

# echo "Starting MariaDB..."
# exec mysqld --user=mysql --datadir="$MYSQL_DATADIR"
