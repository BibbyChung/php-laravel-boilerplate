FROM php:7-fpm-alpine AS build

RUN apk update && apk upgrade
RUN apk add --update curl \
  openssl \
  libpng-dev \
  autoconf \
  automake \
  make \
  g++ \
  libtool \
  nasm \
  nodejs \
  nodejs-npm

RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer

WORKDIR /var/www/app

COPY ./app/package.json /var/www/app/package.json
COPY ./app/package-lock.json /var/www/app/package-lock.json
RUN npm i

COPY ./app/ /var/www/app/
RUN composer install

RUN npm run prod

RUN rm /var/cache/apk/* && \
    mkdir -p /var/www


FROM php:7-fpm-alpine

RUN apk update && apk upgrade
RUN apk add --update wget \
  curl \
  git \
  grep \
  build-base \
  libmemcached-dev \
  libmcrypt-dev \
  libxml2-dev \
  imagemagick-dev \
  pcre-dev \
  libtool \
  make \
  autoconf \
  g++ \
  cyrus-sasl-dev \
  libgsasl-dev \
  supervisor \
  nginx

RUN docker-php-ext-install mysqli mbstring pdo pdo_mysql tokenizer xml
RUN pecl channel-update pecl.php.net \
    && pecl install memcached \
    && pecl install imagick \
    && docker-php-ext-enable memcached \
    && docker-php-ext-enable imagick \
    && pecl install mcrypt-1.0.1

RUN mkdir -p /run/nginx

RUN rm /var/cache/apk/* && \
    mkdir -p /var/www

WORKDIR /var/www

COPY ./ops/heroku/phpfpm.www.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./ops/heroku/nginx.default.conf /etc/nginx/conf.d/default.conf
COPY ./ops/heroku/supervisord.conf /etc/supervisord.conf
COPY --from=build /var/www/app/ /var/www/app/
COPY ./ops/heroku/php.env /var/www/app/.env
COPY ./ops/heroku/start.sh /var/www/app/start.sh

RUN chmod +x /var/www/app/start.sh

CMD export PORT=$PORT && bash /var/www/app/start.sh
