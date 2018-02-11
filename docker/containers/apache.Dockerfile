FROM php:5.6-apache
MAINTAINER Tyler Mulligan <z@xnz.me>

ENV PHPBB_DOWNLOAD_URL="https://download.phpbb.com/pub/release/3.0/3.0.6/phpBB-3.0.6.tar.bz2"

RUN apt-get update && apt-get install -y \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libmcrypt-dev \
		libpng-dev \
	&& docker-php-ext-configure mysqli \
	&& docker-php-ext-install mysqli \
	&& docker-php-ext-install -j$(nproc) iconv mcrypt \
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
	&& docker-php-ext-install -j$(nproc) gd

RUN rm /etc/apache2/sites-enabled/000-default.conf && mkdir -p /var/www/forums.alientrap.local/public_html

COPY docker/containers/apache/sites-available/forums.alientrap.local.conf /etc/apache2/sites-enabled/
COPY docker/containers/php/php.ini /usr/local/etc/php/
COPY docker/containers/php/php.ini /etc/php5/cli

RUN curl -sL ${PHPBB_DOWNLOAD_URL} | tar xj -C "${PWD}" \
  && mv /var/www/html/phpBB3/* /var/www/forums.alientrap.local/public_html \
  && rm -rf /var/www/forums.alientrap.local/public_html/install

COPY config/config.php /var/www/forums.alientrap.local/public_html/config.php
COPY config/styles/darkfx /var/www/forums.alientrap.local/public_html/styles/darkfx
