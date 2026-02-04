FROM debian:12

# Install php-fpm and extensions needed for WordPress
RUN apt-get update && apt-get install -y \
	php8.2-fpm \
	php8.2-mysql \
	php8.2-curl \
	php8.2-gd \
	php8.2-intl \
	php8.2-mbstring \
	php8.2-soap \
	php8.2-xml \
	php8.2-zip \
	wget \
	curl \
	&& ln -s /usr/sbin/php8.2 /usr/local/bin/php-fpm \
	&& rm -rf /var/lib/apt/lists/*

#Create WordPress directory
WORKDIR /var/www/html

#Copy config and setup
COPY ./conf/my.cnf /etc/php/8.2/fpm/pool.d/
COPY ./tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

#php-fpm will listen on port 9000 by default
EXPOSE 9000

CMD ["/usr/local/bin/entrypoint.sh"]

############ OVA 4 version - works but somethin'g missing, php does not let me log in
# FROM debian:12

# # Install php-fpm, wp-cli prerequisites, and MariaDB client for health checks
# RUN apt-get update \
# 	&& DEBIAN_FRONTEND=noninteractive apt-get install -y php-fpm php-mysql curl unzip mariadb-client \
# 	&& curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
# 	&& chmod +x /usr/local/bin/wp \
# 	&& apt-get clean \
# 	&& rm -rf /var/lib/apt/lists/*

# WORKDIR /var/www/html

# COPY ./tools/entrypoint.sh /usr/local/bin/entrypoint.sh
# RUN chmod +x /usr/local/bin/entrypoint.sh

# # Configure php-fpm pool to listen on TCP 0.0.0.0:9000 so nginx can connect over the network
# RUN set -eux; \
# 	for f in /etc/php/*/fpm/pool.d/www.conf; do \
# 		if [ -f "$f" ]; then \
# 			sed -ri 's/^;?\s*listen\s*=.*/listen = 0.0.0.0:9000/' "$f"; \
# 			sed -ri 's/^;?\s*listen\.owner\s*=.*/listen.owner = www-data/' "$f" || true; \
# 			sed -ri 's/^;?\s*listen\.group\s*=.*/listen.group = www-data/' "$f" || true; \
# 		fi; \
# 	done

# # php-fpm will listen on port 9000 by default (fastcgi)
# EXPOSE 9000

# CMD ["/usr/local/bin/entrypoint.sh"]