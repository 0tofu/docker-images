FROM alpine:3.4
MAINTAINER otofu <otofu.xxx+docker@gmail.com>

RUN apk --update add --no-cache dnsmasq \
 && rm -rf /var/cache/apk/*

RUN mkdir /etc/dnsmasq.d \
 && sed -i -e "s|#conf-dir=/etc/dnsmasq.d/|conf-dir=/etc/dnsmasq.d/|" /etc/dnsmasq.conf

EXPOSE 53 53/udp

ENTRYPOINT ["dnsmasq", "-k" ]

