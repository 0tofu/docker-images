FROM nginx:1.12-alpine
MAINTAINER otofu <otofu.xxx+docker@gmail.com>

RUN apk --update add --no-cache tzdata \
 && cp /usr/share/zoninfo/Asia/Tokyo /etc/localtime \
 && echo "Asia/Tokyo" > /etc/timezone \
 && apk del tzdata \
 && rm -rf /var/cache/apk/*

COPY ./etc /etc
