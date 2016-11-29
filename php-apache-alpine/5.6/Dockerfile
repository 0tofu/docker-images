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

ENV PHP_GPG_KEYS 0BD78B5F97500D450838F95DFE857D9A90D90EC1 6E4F6AB321FDC07F2C332E3AC2BF0BC433CFC8B3
ENV PHP_VERSION 5.6.28
ENV PHP_URL="https://secure.php.net/get/php-${PHP_VERSION}.tar.xz/from/this/mirror"
ENV PHP_ASC_URL="https://secure.php.net/get/php-${PHP_VERSION}.tar.xz.asc/from/this/mirror"
ENV PHP_SHA256="07187ba2870f89cef334cd2ad6cb801aeec5eaf283da0293a9a6be75d6786d11"
ENV PHP_MD5="1e01c66b2e67ab3b56a6180ee560fe4c"

RUN set -xe \
  && apk --update add --no-cache --virtual .build-deps \
      $PHPIZE_DEPS \
      curl-dev \
      gnupg \
      libedit-dev \
      libjpeg-turbo-dev \
      libpng-dev \
      libxml2-dev \
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
  && make -j "$(getconf _NPROCESSORS_ONLN)" \
  && make install \
  && { find /usr/local/bin /usr/local/sbin -type f -perm +0111 -exec strip --strip-all '{}' + || true; } \
  && make clean \
  && docker-php-source delete \
  && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
  && docker-php-ext-install gd mbstring opcache mysqli pdo pdo_mysql zip \
  && pecl install uploadprogress && docker-php-ext-enable uploadprogress \
  && runDeps="$( \
    scanelf --needed --nobanner --recursive /usr/local \
      | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
      | sort -u \
      | xargs -r apk info --installed \
      | sort -u \
  )" \
  && apk add --virtual .php-rundeps $runDeps \
  && apk del --purge .build-deps

# phpmyadminのインストール
ENV PHP_MY_ADMIN_VERSION 4.6.4
ENV PHP_MY_ADMIN_URL https://files.phpmyadmin.net/phpMyAdmin/${PHP_MY_ADMIN_VERSION}/phpMyAdmin-${PHP_MY_ADMIN_VERSION}-all-languages.tar.gz
ENV PHP_MY_ADMIN_DIR /var/www/pma

COPY ./pma/phpmyadmin.keyring /tmp/
RUN set -xe; \
    apk --update add --no-cache --virtual .fetch-deps gnupg openssl; \
    export GNUPGHOME="$(mktemp -d)" && \
    curl --output phpMyAdmin.tar.gz --location ${PHP_MY_ADMIN_URL} && \
    curl --output phpMyAdmin.tar.gz.asc --location ${PHP_MY_ADMIN_URL}.asc && \
    gpgv --keyring /tmp/phpmyadmin.keyring phpMyAdmin.tar.gz.asc phpMyAdmin.tar.gz && \
    rm -rf "${GNUPGHOME}" && \
    tar xzf phpMyAdmin.tar.gz && \
    rm -f phpMyAdmin.tar.gz phpMyAdmin.tar.gz.asc && \
    mv phpMyAdmin-${PHP_MY_ADMIN_VERSION}-all-languages ${PHP_MY_ADMIN_DIR} && \
    cd ${PHP_MY_ADMIN_DIR} \
    rm -rf ./js/jquery/src/ \
           ./js/openlayers/src/ \
           ./setup/ \
           ./examples/ \
           ./test/ \
           ./po/ \
           ./templates/test/ \
           ./phpunit.xml.* \
           ./build.xml \
           ./composer.json \
           ./RELEASE-DATE-${PHP_MY_ADMIN_VERSION} && \
    chown -R www-data:www-data ${PHP_MY_ADMIN_DIR} && \
    find ${PHP_MY_ADMIN_DIR} -type d -exec chmod 755 {} \; && \
    find ${PHP_MY_ADMIN_DIR} -type f -exec chmod 644 {} \; && \
    apk del --purge .fetch-deps
COPY ./pma/config.inc.php ${PHP_MY_ADMIN_DIR}
COPY ./pma/run.sh ${PHP_MY_ADMIN_DIR}/run.sh
RUN chmod u+rwx ${PHP_MY_ADMIN_DIR}/run.sh && ${PHP_MY_ADMIN_DIR}/run.sh

COPY ./php/conf ${PHP_INI_DIR}
COPY ./httpd/conf /usr/local/apache2/conf/other
