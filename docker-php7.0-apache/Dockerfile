FROM php:7.0-apache
MAINTAINER otofu <otofu.xxx+docker@gmail.com>

RUN a2enmod rewrite expires vhost_alias

RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev libpq-dev git ssmtp && \
    rm -rf /var/lib/apt/lists/* && apt-get clean && \
    docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr && \
    docker-php-ext-install gd mbstring opcache mysqli pdo pdo_mysql zip

RUN cd /tmp && \
    git clone https://github.com/php/pecl-php-uploadprogress.git && \
    cd pecl-php-uploadprogress && \
    phpize && \
    ./configure && \
    make && make install && \
    rm -rf /tmp/pecl-php-uploadprogress

RUN sed -i -e 's/mailhub=mail/mailhub=mailcatcher.l:1025/' -e 's/#FromLineOverride=YES/FromLineOverride=YES/' /etc/ssmtp/ssmtp.conf

COPY ./etc /etc
COPY ./usr /usr
