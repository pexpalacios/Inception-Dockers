#nginx must use TLSv1.2 or TLSv1.3 only. Domain must be configured to use HTTPS. Domain must be penpalac.42.fr
FROM debian:12

RUN apt-get update \
	&& apt-get install -y nginx openssl \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Generate a self-signed cert (for local/testing only)
RUN mkdir -p /etc/nginx/ssl \
	&& openssl req -x509 -nodes -days 365 \
		-subj "/CN=penpalac.42.fr" \
		-newkey rsa:2048 \
		-keyout /etc/nginx/ssl/selfsigned.key \
		-out /etc/nginx/ssl/selfsigned.crt

COPY ./conf/default.conf /etc/nginx/conf.d/default.conf

# Nginx will serve HTTPS and proxy to the wordpress php-fpm container on 9000
EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
