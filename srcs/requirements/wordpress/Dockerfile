FROM debian:12

# Install php-fpm and extensions needed for WordPress
RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y php-fpm php-mysql curl unzip \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

COPY ./tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Configure php-fpm pool to listen on TCP 0.0.0.0:9000 so nginx can connect over the network
RUN set -eux; \
	for f in /etc/php/*/fpm/pool.d/www.conf; do \
		if [ -f "$f" ]; then \
			sed -ri 's/^;?\s*listen\s*=.*/listen = 0.0.0.0:9000/' "$f"; \
			sed -ri 's/^;?\s*listen\.owner\s*=.*/listen.owner = www-data/' "$f" || true; \
			sed -ri 's/^;?\s*listen\.group\s*=.*/listen.group = www-data/' "$f" || true; \
		fi; \
	done

# php-fpm will listen on port 9000 by default (fastcgi)
EXPOSE 9000

CMD ["/usr/local/bin/entrypoint.sh"]
