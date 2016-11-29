FROM ruby:2.3-alpine
MAINTAINER otofu <otofu.xxx+docker@gmail.com>

RUN apk --update add --no-cache libstdc++ build-base openssl-dev sqlite sqlite-dev ruby-dev tzdata \
 && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
 && echo "Asia/Tokyo" > /etc/timezone \
 && gem install mailcatcher \
 && apk del build-base ruby-dev tzdata \
 && rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

EXPOSE 1025 1080

ENTRYPOINT ["mailcatcher", "--foreground", "--ip=0.0.0.0"]
