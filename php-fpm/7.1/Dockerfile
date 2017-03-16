FROM php:7.1-fpm-alpine
MAINTAINER otofu <otofu.xxx+docker@gmail.com>

ENV PHPIZE_DEPS autoconf file g++ gcc libc-dev make pkgconf re2c
ENV PHP_INI_DIR /usr/local/etc/php

RUN set -x \
  && mkdir -p ${PHP_INI_DIR}/conf.d \
  && apk --update add --no-cache --virtual .persistent-deps ca-certificates curl tar xz vim

RUN set -x \
  && apk --update add --no-cache ssmtp

RUN set -xe \
  && apk --update add --no-cache --virtual .build-deps \
      $PHPIZE_DEPS \
      curl-dev \
      gnupg \
      libmcrypt-dev \
      libedit-dev \
      libjpeg-turbo-dev \
      libpng-dev \
      libxml2-dev \
      openssl \
      openssl-dev \
      sqlite-dev \
      git \
  && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
  && docker-php-ext-install gd mbstring opcache mysqli pdo pdo_mysql zip bcmath mcrypt \
  && pecl install apcu \
  && docker-php-ext-enable apcu \
  && cd /tmp && \
      git clone https://github.com/php/pecl-php-uploadprogress.git && \
      cd pecl-php-uploadprogress && \
      phpize && \
      ./configure && \
      make && make install && \
      rm -rf /tmp/pecl-php-uploadprogress \
  && docker-php-ext-enable uploadprogress \
  && runDeps="$( \
      scanelf --needed --nobanner --recursive /usr/local \
      | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
      | sort -u \
      | xargs -r apk info --installed \
      | sort -u \
    )" \
  && apk add --virtual .php-rundeps $runDeps \
  && apk del --purge .build-deps

COPY ./etc /etc
COPY ./usr /usr
