#!/bin/bash
set -e

WP_PATH="/var/www/html"

# Read password from secret file
if [ -n "$WP_DB_PASSWORD_FILE" ] && [ -f "$WP_DB_PASSWORD_FILE" ]; then
    WP_DB_PASSWORD=$(cat "$WP_DB_PASSWORD_FILE")
    export WP_DB_PASSWORD
fi

echo "Setting up WordPress..."

# Download and configure WordPress if not present
if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "Downloading WordPress..."
    wget -q https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz
    tar -xzf /tmp/wordpress.tar.gz -C /tmp
    rm /tmp/wordpress.tar.gz

    # Copy only missing files (avoid overwriting existing content)
    cp -rn /tmp/wordpress/* "$WP_PATH" || true
    rm -rf /tmp/wordpress

    # Fetch security salts from WordPress API
    WP_SALTS=$(wget -qO- https://api.wordpress.org/secret-key/1.1/salt/)

    # Create wp-config.php
    cat > "$WP_PATH/wp-config.php" << EOF
<?php
define('DB_NAME', '${WP_DB_NAME}');
define('DB_USER', '${WP_DB_USER}');
define('DB_PASSWORD', '${WP_DB_PASSWORD}');
define('DB_HOST', '${WP_DB_HOST}');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

\$table_prefix = '${WP_TABLE_PREFIX:-wp_}';
${WP_SALTS}

define('WP_DEBUG', false);

if ( !defined('ABSPATH') )
    define('ABSPATH', __DIR__ . '/');

require_once ABSPATH . 'wp-settings.php';
EOF

    # Set secure permissions
    find "$WP_PATH" -type d -exec chmod 750 {} \;
    find "$WP_PATH" -type f -exec chmod 640 {} \;
    chown -R www-data:www-data "$WP_PATH"

    echo "WordPress setup complete."
    wp core install --allow-root\
    --url="https://${DOMAIN_NAME}"\
    --title="${WP_TITLE}"\
    --admin_user="${WP_WEB_ADMIN}"\
    --admin_password="$(cat /run/secrets/wp_admin_password)"\
    --admin_email="${WEB_ADMIN_EMAIL}"\
    --skip-email

    wp user create --allow-root \
    ${WP_WEB_USER} \
    ${WEB_USER_EMAIL} \
    --role=author \
    --user_pass="$(cat /run/secrets/wp_user_password)" \
    
    # Ensure WordPress URLs are set to HTTPS
    wp option update --allow-root home "https://${DOMAIN_NAME}"
    wp option update --allow-root siteurl "https://${DOMAIN_NAME}"

else
    echo "WordPress already initialized, skipping setup."
fi

echo "Starting PHP-FPM..."
exec php-fpm8.2 -F