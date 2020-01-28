FROM php:7.3-apache

# パッケージインストール.
RUN set -ex \
 && apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends vim wget curl msmtp msmtp-mta git unzip locales

# PHP拡張インストール.
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/
RUN set -ex \
 && install-php-extensions \
    gd \
    opcache \
    mysqli \
    pdo_mysql \
    pdo_pgsql \
    zip \
    gmp \
    ldap \
    intl \
    xdebug
# uploadprogressはソースより取得する必要がある.
RUN mkdir -p /usr/src/php/ext/uploadprogress \
 && up_url="https://github.com/wodby/pecl-php-uploadprogress/archive/latest.tar.gz" \
 && wget -qO- "${up_url}" | tar xz --strip-components=1 -C /usr/src/php/ext/uploadprogress \
 && docker-php-ext-install uploadprogress

# aptの不要ファイル整理.
RUN set -ex \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# localeの設定.
RUN { \
  echo 'en_US.UTF-8 UTF-8'; \
  echo 'ja_JP.UTF-8 UTF-8'; \
} > /etc/locale.gen \
 && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# composerの導入.
ENV COMPOSER_ALLOW_SUPERUSER 1
COPY --from=composer /usr/bin/composer /usr/bin/composer
RUN set -ex \
 && composer global require hirak/prestissimo
ENV PATH ./vendor/bin:/root/.composer/vendor/bin/drush:${PATH}

# Apachのバーチャルホスト有効化.
RUN a2enmod rewrite vhost_alias

# opcacheの設定.
RUN { \
  echo 'opcache.enable=1'; \
  echo 'opcache.enable_cli=1'; \
  echo 'opcache.memory_consumption=128'; \
  echo 'opcache.interned_strings_buffer=8'; \
  echo 'opcache.max_accelerated_files=4000'; \
  echo 'opcache.revalidate_freq=2'; \
  echo 'opcache.fast_shutdown=1'; \
} > /usr/local/etc/php/conf.d/opcache-recommended.ini
