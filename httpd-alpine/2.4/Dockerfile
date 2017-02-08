FROM alpine:3.4
MAINTAINER otofu <otofu.xxx+docker@gmail.com>

RUN addgroup -g 82 -S www-data \
  && adduser -u 82 -D -S -G www-data www-data

RUN apk --update add --no-cache tzdata \
  && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
  && echo "Asia/Tokyo" > /etc/timezone \
  && apk --purge del tzdata \
  && rm -rf /var/cache/apk/*

ENV HTTPD_PREFIX /usr/local/apache2
ENV PATH $HTTPD_PREFIX/bin:$PATH

RUN mkdir -p ${HTTPD_PREFIX}/conf/other \
  && chown -R www-data:www-data "$HTTPD_PREFIX" \
  && mkdir -p /var/www/html \
  && chown -R www-data:www-data /var/www

WORKDIR $HTTPD_PREFIX

ENV HTTPD_VERSION 2.4.25
ENV HTTPD_SHA1 bd6d138c31c109297da2346c6e7b93b9283993d2
ENV HTTPD_GPG_KEY A93D62ECC3C8EA12DB220EC934EA76E6791485A8
ENV HTTPD_BZ2_URL https://www.apache.org/dyn/closer.cgi?action=download&filename=httpd/httpd-$HTTPD_VERSION.tar.bz2
ENV HTTPD_ASC_URL https://www.apache.org/dist/httpd/httpd-$HTTPD_VERSION.tar.bz2.asc

ENV APACHE_RUN_USER  www-data
ENV APACHE_RUN_GROUP www-data

RUN set -x \
  && runDeps='apr-dev apr-util-dev perl' \
  && apk --update add --no-cache --virtual .build-deps \
      $runDeps \
      ca-certificates \
      gcc \
      gnupg \
      libc-dev \
      make \
      openssl \
      openssl-dev \
      pcre-dev \
      tar \
  && wget -O httpd.tar.bz2 "$HTTPD_BZ2_URL" \
  && echo "$HTTPD_SHA1 *httpd.tar.bz2" | sha1sum -c - \
  && wget -O httpd.tar.bz2.asc "$HTTPD_ASC_URL" \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys $HTTPD_GPG_KEY \
  && gpg --batch --verify httpd.tar.bz2.asc httpd.tar.bz2 \
  && rm -r "$GNUPGHOME" httpd.tar.bz2.asc \
  && mkdir -p src \
  && tar -xvf httpd.tar.bz2 -C src --strip-components=1 \
  && rm httpd.tar.bz2 \
  && cd src \
  && ./configure \
    --prefix="$HTTPD_PREFIX" \
    --enable-mods-shared=reallyall \
    --with-mpm=prefork \
  && make -j"$(getconf _NPROCESSORS_ONLN)" \
  && make install \
  && cd .. \
  && rm -r src \
  && sed -ri \
    -e 's/User daemon/User www-data/' \
    -e 's/Group daemon/Group www-data/' \
    -e 's!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g' \
    -e 's!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g' \
    -e 's/#LoadModule rewrite_module/LoadModule rewrite_module/' \
    -e 's/#LoadModule vhost_alias_module/LoadModule vhost_alias_module/' \
    -e 's/#LoadModule expires_module/LoadModule expires_module/' \
    -e 's/#LoadModule include_module modules\/mod_include.so/LoadModule include_module modules\/mod_include.so/' \
    -e '$ a IncludeOptional conf/other/*.conf' \
    "$HTTPD_PREFIX/conf/httpd.conf" \
  && runDeps="$runDeps $( \
    scanelf --needed --nobanner --recursive /usr/local \
      | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
      | sort -u \
      | xargs -r apk info --installed \
      | sort -u \
  )" \
  && apk --update add --virtual .httpd-rundeps $runDeps \
  && apk --purge del .build-deps

COPY ./usr /usr

EXPOSE 80

CMD ["httpd-foreground"]
