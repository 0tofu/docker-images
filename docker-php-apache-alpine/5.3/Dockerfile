FROM otofu/httpd-alpine:2.4
MAINTAINER otofu <otofu.xxx+docker@gmail.com>

ENV PHPIZE_DEPS autoconf file g++ gcc libc-dev make pkgconf re2c
ENV PHP_INI_DIR /usr/local/etc/php

RUN set -x \
  && mkdir -p ${PHP_INI_DIR}/conf.d \
  && apk --update add --no-cache --virtual .persistent-deps ca-certificates curl tar xz

RUN set -x \
  && apk --update add --no-cache ssmtp \
  && sed -i \
    -e 's/mailhub=mail/mailhub=mailcatcher.l:1025/' \
    -e '$ a FromLineOverride=YES' \
    /etc/ssmtp/ssmtp.conf

COPY ./php/bin /usr/local/bin

ENV PHP_GPG_KEYS 0B96609E270F565C13292B24C13C70B87267B52D 0A95E9A026542D53835E3F3A7DEC4E69FC9C83D7
ENV PHP_VERSION 5.3.29
ENV PHP_URL="https://secure.php.net/get/php-${PHP_VERSION}.tar.xz/from/this/mirror"
ENV PHP_ASC_URL="https://secure.php.net/get/php-${PHP_VERSION}.tar.xz.asc/from/this/mirror"
ENV PHP_SHA256="8438c2f14ab8f3d6cd2495aa37de7b559e33b610f9ab264f0c61b531bf0c262d"
ENV PHP_MD5="dcff9c881fe436708c141cfc56358075"

RUN set -xe \
  && apk --update add --no-cache --virtual .build-deps \
      $PHPIZE_DEPS \
      curl-dev \
      git \
      gnupg \
      libedit-dev \
      libjpeg-turbo-dev \
      libpng-dev \
      libxml2-dev \
      mariadb-dev \
      openssl \
      openssl-dev \
      sqlite-dev \
  && mkdir -p /usr/src \
  && cd /usr/src \
  && wget -O php.tar.xz "$PHP_URL" \
  && echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c - \
  && echo "$PHP_MD5 *php.tar.xz" | md5sum -c - \
  && wget -O php.tar.xz.asc "$PHP_ASC_URL" \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys $PHP_GPG_KEYS \
  && gpg --batch --verify php.tar.xz.asc php.tar.xz \
  && rm -r "$GNUPGHOME" \
  && docker-php-source extract \
  && cd /usr/src/php \
  && ./configure \
    --with-apxs2="/usr/local/apache2/bin/apxs" \
    --with-config-file-path="$PHP_INI_DIR" \
    --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
    --disable-cgi \
    --enable-ftp \
    --enable-mbstring \
    --enable-mysqlnd \
    --with-curl \
    --with-libedit \
    --with-openssl \
    --with-zlib \
    --enable-maintainer-zts \
  && make -j "$(getconf _NPROCESSORS_ONLN)" \
  && make install \
  && { find /usr/local/bin /usr/local/sbin -type f -perm +0111 -exec strip --strip-all '{}' + || true; } \
  && make clean \
  && docker-php-source delete \
  && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
  && docker-php-ext-install gd mbstring mysqli pdo pdo_mysql zip \
  && pecl install uploadprogress && docker-php-ext-enable uploadprogress \
  && cd /tmp \
  && git clone https://github.com/zendtech/ZendOptimizerPlus.git \
  && cd ZendOptimizerPlus \
  && phpize \
  && ./configure --with-php-config=/usr/local/bin/php-config \
  && make && make install \
  && cd /tmp && rm -rf /tmp/ZendOptimizerPlus \
  && runDeps="$( \
    scanelf --needed --nobanner --recursive /usr/local \
      | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
      | sort -u \
      | xargs -r apk info --installed \
      | sort -u \
  )" \
  \
  && apk add --virtual .php-rundeps $runDeps \
  && apk del --purge .build-deps

COPY ./php/conf ${PHP_INI_DIR}
COPY ./httpd/conf /usr/local/apache2/conf/other
