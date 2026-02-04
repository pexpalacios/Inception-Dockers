#!/bin/bash
set -e

chown -R www-data:www-data /var/www/html || true

# If no wordpress files present, download and extract latest wordpress into the volume
if [ ! -f /var/www/html/wp-config.php ] && [ -z "$(ls -A /var/www/html 2>/dev/null)" ]; then
	echo "Installing latest WordPress into /var/www/html..."
	mkdir -p /var/www/html
	curl -fsSL https://wordpress.org/latest.tar.gz -o /tmp/wordpress.tar.gz
	tar -xzf /tmp/wordpress.tar.gz -C /tmp
	cp -a /tmp/wordpress/. /var/www/html/
	rm -rf /tmp/wordpress /tmp/wordpress.tar.gz
	chown -R www-data:www-data /var/www/html
fi

# Locate php-fpm binary and run it in foreground
PHPFPM_BIN=""
for cmd in php-fpm php-fpm8.2 php-fpm8.1 php-fpm7.4; do
	if command -v "$cmd" >/dev/null 2>&1; then
		PHPFPM_BIN=$(command -v "$cmd")
		break
	fi
done

if [ -z "$PHPFPM_BIN" ]; then
	echo "php-fpm binary not found in image. Exiting." >&2
	exit 1
fi

exec "$PHPFPM_BIN" -F

############### OVA 4 version - works until I try to acces login
#!/bin/bash
# set -e

# WP_PATH=/var/www/html
# DB_HOST=${MYSQL_HOST:-mariadb}
# DB_NAME=${MYSQL_DATABASE:-wordpress}
# DB_USER=${MYSQL_USER:-wordpress}
# DB_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")

# WP_URL=${WP_URL:-https://${DOMAIN_NAME:-localhost}}
# WP_TITLE=${WP_TITLE:-Inception}
# WP_ADMIN_PASSWORD=$(cat "$WP_ADMIN_PASSWORD_FILE")
# WP_SUBSCRIBER_PASSWORD=$(cat "$WP_SUBSCRIBER_PASSWORD_FILE")

# echo "ADMIN PASS = ${WP_ADMIN_PASSWORD} & SUBS PASS = ${WP_SUBSCRIBER_PASSWORD}"

# run_wp() {
# 	su -s /bin/bash www-data -c "WP_CLI_CACHE_DIR=/tmp/.wp-cli-cache wp --path=$WP_PATH $*"
# }

# chown -R www-data:www-data "$WP_PATH" || true

# # If no wordpress files present, download and extract latest wordpress into the volume
# if [ ! -f "$WP_PATH/wp-config.php" ] && [ -z "$(ls -A "$WP_PATH" 2>/dev/null)" ]; then
# 	echo "Installing latest WordPress into $WP_PATH..."
# 	mkdir -p "$WP_PATH"
# 	curl -fsSL https://wordpress.org/latest.tar.gz -o /tmp/wordpress.tar.gz
# 	tar -xzf /tmp/wordpress.tar.gz -C /tmp
# 	cp -a /tmp/wordpress/. "$WP_PATH"/
# 	rm -rf /tmp/wordpress /tmp/wordpress.tar.gz
# 	chown -R www-data:www-data "$WP_PATH"
# fi

# # Wait for MariaDB to be reachable
# echo "Waiting for database at $DB_HOST..."
# for i in {30..0}; do
# 	if mariadb -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1" >/dev/null 2>&1; then
# 		echo "Database is up."
# 		break
# 	fi
# 	sleep 1
# done

# if [ "$i" = "0" ]; then
# 	echo "MariaDB is unreachable. Exiting." >&2
# 	exit 1
# fi

# # Create wp-config.php if needed
# if [ ! -f "$WP_PATH/wp-config.php" ]; then
# 	echo "Generating wp-config.php..."
# 	run_wp config create --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASSWORD" --dbhost="$DB_HOST" --skip-check
# fi

# # Prevent admin usernames that contain the substring "admin"
# if echo "$WP_ADMIN_USER" | grep -qi "admin"; then
# 	echo "Refusing to create admin user containing the substring 'admin'. Choose a different WP_ADMIN_USER." >&2
# 	exit 1
# fi

# # Install WordPress if not already installed
# if ! run_wp core is-installed >/dev/null 2>&1; then
# 	echo "Running wp core install..."
# 	run_wp core install \
# 		--url="$WP_URL" \
# 		--title="$WP_TITLE" \
# 		--admin_user="$WP_ADMIN_USER" \
# 		--admin_password="$WP_ADMIN_PASSWORD" \
# 		--admin_email="$WP_ADMIN_EMAIL"
# fi

# # Ensure subscriber user exists
# if ! run_wp user get "$WP_SUBSCRIBER_USER" >/dev/null 2>&1; then
# 	run_wp user create "$WP_SUBSCRIBER_USER" "$WP_SUBSCRIBER_EMAIL" --role=subscriber --user_pass="$WP_SUBSCRIBER_PASSWORD"
# fi

# # Locate php-fpm binary and run it in foreground
# PHPFPM_BIN=""
# for cmd in php-fpm php-fpm8.2 php-fpm8.1 php-fpm7.4; do
# 	if command -v "$cmd" >/dev/null 2>&1; then
# 		PHPFPM_BIN=$(command -v "$cmd")
# 		break
# 	fi
# done

# if [ -z "$PHPFPM_BIN" ]; then
# 	echo "php-fpm binary not found in image. Exiting." >&2
# 	exit 1
# fi

# exec "$PHPFPM_BIN" -F
