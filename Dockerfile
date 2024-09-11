# Installs WordPress with wp-cli (wp.cli.org) installed
FROM wordpress:php8.3-fpm

# Add sudo in order to run wp-cli as the www-data user
RUN apt-get update && apt-get install -y sudo less default-mysql-client libxml2-dev git

# Add soap
RUN docker-php-ext-install soap

# Add ruby/compass
# RUN apt-get update && apt-get install -y ruby-full && gem update && gem install sass && gem install compass

# Add nodejs
RUN apt-get update; exit 0
RUN apt-get install -y gnupg
RUN curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
RUN apt-get install -y nodejs

# Add XDebug
RUN pecl install xdebug \
	&& docker-php-ext-enable xdebug

RUN echo 'zend_extension="/usr/local/lib/php/extensions/no-debug-non-zts-20200930/xdebug.so"' >> /usr/local/etc/php/conf.d/conf.ini \
	&& mkdir /tmp/xdebug_profiler && chown www-data:www-data /tmp/xdebug_profiler

# Add composer
RUN cd ~ && curl -sS https://getcomposer.org/installer -o composer-setup.php && php composer-setup.php --install-dir=/usr/local/bin --filename=composer && rm composer-setup.php

# Add pt_BR locales
RUN apt-get install -y locales \
    && echo '' >> /usr/share/locale/locale.alias \
    && sed -i 's/# pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen \
    && sed -i 's/# pt_BR ISO-8859-1/pt_BR ISO-8859-1/' /etc/locale.gen \
    && locale-gen

# Add WP-CLI
RUN curl -o /bin/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
COPY wp-su.sh /bin/wp
RUN chmod +x /bin/wp-cli.phar /bin/wp

RUN echo 'memory_limit = 512M' >> /usr/local/etc/php/conf.d/conf.ini

# Cleanup
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
