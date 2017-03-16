FROM nginx:1.11-alpine
MAINTAINER otofu <otofu.xxx+docker@gmail.com>

RUN addgroup -g 82 -S www-data \
  && adduser -u 82 -D -S -G www-data www-data

RUN apk --update add --no-cache tzdata \
 && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
 && echo "Asia/Tokyo" > /etc/timezone \
 && apk del tzdata \
 && rm -rf /var/cache/apk/*

COPY ./etc /etc
