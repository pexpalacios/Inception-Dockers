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
