FROM php:latest

RUN apt-get update && apt-get install -y \
        git \
        unzip \
        curl \
        libicu-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng12-dev \
        libmemcached-dev \
        default-jre \
        xvfb \
        chromedriver \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/php7.tar.gz" && \
    mkdir -p memcached && \
    tar -C memcached -zxvf /tmp/memcached.tar.gz --strip 1 && \
    ( \
        cd memcached && \
        phpize && \
        ./configure && \
        make -j$(nproc) && \
        make install \
    ) && \
    rm -r memcached && \
    rm /tmp/memcached.tar.gz

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) pdo_mysql intl gd exif fileinfo \
    && docker-php-ext-enable memcached \
    && echo "memory_limit=-1" > $PHP_INI_DIR/conf.d/memory-limit.ini
