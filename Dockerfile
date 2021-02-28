FROM alpine:latest
ENV DOCROOT /docroot
WORKDIR $DOCROOT

RUN apk upgrade --no-cache \
    && apk --update --no-cache add bash sudo wget curl unzip tzdata supervisor nginx php7 php7-fpm php7-gd php7-apcu php7-ctype php7-curl php7-dom php7-fileinfo php7-ftp php7-iconv php7-intl php7-json php7-mbstring php7-mcrypt php7-mysqlnd php7-opcache php7-openssl php7-pdo php7-pdo_sqlite php7-phar php7-posix php7-session php7-simplexml php7-sqlite3 php7-tokenizer php7-xml php7-xmlreader php7-xmlwriter php7-zlib \
    && sed -i -E "s/127\.0\.0\.1:9000/\/var\/run\/php-fpm\/php-fpm.sock/" /etc/php7/php-fpm.d/www.conf \
    && mkdir /var/run/php-fpm \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && mkdir -p /run/nginx \
    && mkdir -p /home/Software \
    && mkdir -p /var/tmp/nginx/client_body \
    && sed -i -E "s/error_log .+/error_log \/dev\/stderr warn;/" /etc/nginx/nginx.conf \
    && sed -i -E "s/access_log .+/access_log \/dev\/stdout main;/" /etc/nginx/nginx.conf \
    && mkdir -p /etc/supervisor.d/ \
    && rm -rf /var/cache/apk/*

ENV PHP_INI_DIR /etc/php7
COPY php.ini $PHP_INI_DIR/
COPY supervisor.programs.ini /etc/supervisor.d/
COPY start.sh /

RUN adduser -D myuser \
    && chmod a+x /start.sh \
    && chmod -R a+w /etc/php7/php-fpm.d \
    && chmod -R a+w /etc/nginx \
    && chmod a+w /var/run/php-fpm \
    && chmod -R a+w /run/nginx \
    && chmod -R a+wx /var/tmp/nginx \
    && chmod -R a+r /etc/supervisor* \
    && sed -i -E "s/^file=\/run\/supervisord\.sock/file=\/run\/supervisord\/supervisord.conf/" /etc/supervisord.conf \
    && mkdir -p /run/supervisord \
    && chmod -R a+w /run/supervisord \
    && chmod -R a+w /var/log \
    && echo "myuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ONBUILD COPY / $DOCROOT/
ONBUILD RUN chmod -R a+w $DOCROOT
CMD ["/start.sh"]
