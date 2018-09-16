FROM ubuntu:xenial

LABEL maintainer="Deepak Gupta <dieepak@gmail.com>"

# Fix debconf warnings upon build
ENV DEBIAN_FRONTEND=noninteractive

ARG TIMEZONE

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APPLICATION_ADMIN_DOCUMENT_ROOT /var/www/html/admin/public
ENV APPLICATION_API_DOCUMENT_ROOT /var/www/html/api/public

ENV OS_LOCALE="en_US.UTF-8"
RUN apt-get update && apt-get install -y locales && locale-gen ${OS_LOCALE}
ENV LANG=${OS_LOCALE} \
    LANGUAGE=${OS_LOCALE} \
    LC_ALL=${OS_LOCALE} \
    DEBIAN_FRONTEND=noninteractive

ENV APACHE_CONF_DIR=/etc/apache2 \
    PHP_CONF_DIR=/etc/php/5.6 \
    PHP_DATA_DIR=/var/lib/php

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod +x /sbin/entrypoint.sh

RUN	\
	BUILD_DEPS='software-properties-common python-software-properties' \
    && dpkg-reconfigure locales \
	&& apt-get install --no-install-recommends -y $BUILD_DEPS \
	&& add-apt-repository -y ppa:ondrej/php \
	&& add-apt-repository -y ppa:ondrej/apache2 \
	&& apt-get update \
    && apt-get install -y apt-utils vim curl sqlite3 mysql-client vim curl apache2 libapache2-mod-php5.6 php-memcached php5.6-mysql php5.6-pgsql php-redis php5.6-sqlite3 php-xdebug php5.6-bcmath php5.6-bz2 php5.6-dba php5.6-enchant php5.6-gd php5.6-gmp php-igbinary php-imagick php5.6-imap php5.6-interbase php5.6-intl php5.6-ldap php-mongodb php-msgpack php5.6-odbc php5.6-phpdbg php5.6-pspell php-raphf php5.6-recode php5.6-snmp php5.6-soap php-ssh2 php5.6-sybase php-tideways php5.6-tidy php5.6-xmlrpc php5.6-xsl php-yaml php-zmq \
    # Apache settings
    && cp /dev/null ${APACHE_CONF_DIR}/conf-available/other-vhosts-access-log.conf \
    && rm ${APACHE_CONF_DIR}/sites-enabled/000-default.conf ${APACHE_CONF_DIR}/sites-available/000-default.conf \
    && a2enmod rewrite php5.6 \
	# Install composer
	&& curl -sS https://getcomposer.org/installer | php -- --version=1.6.4 --install-dir=/usr/local/bin --filename=composer \
	# Cleaning
	&& apt-get purge -y --auto-remove $BUILD_DEPS \
	&& apt-get autoremove -y \
	&& rm -rf /var/lib/apt/lists/* \
	# Forward request and error logs to docker log collector
	&& ln -sf /dev/stdout /var/log/apache2/access.log \
	&& ln -sf /dev/stderr /var/log/apache2/error.log \
	&& chmod 755 /sbin/entrypoint.sh \
	&& chown www-data:www-data ${PHP_DATA_DIR} -Rf

COPY ./config/apache2.conf ${APACHE_CONF_DIR}/apache2.conf
COPY ./config/ports.conf ${APACHE_CONF_DIR}/ports.conf
COPY ./config/apache-admin-config.conf ${APACHE_CONF_DIR}/sites-enabled/apache-admin-config.conf
COPY ./config/apache-api-config.conf ${APACHE_CONF_DIR}/sites-enabled/apache-api-config.conf
COPY ./config/php-ini-overrides.ini  ${PHP_CONF_DIR}/apache2/conf.d/php-ini-overrides.ini


ENV PHP_DEBUG 1
ENV XDEBUG_HOST="docker.for.mac.localhost"

RUN echo "xdebug.idekey = VSCODE" >> /etc/php/5.6/mods-available/xdebug.ini && \
  echo "xdebug.default_enable = 1" >> /etc/php/5.6/mods-available/xdebug.ini && \
  echo "xdebug.remote_enable = 1" >> /etc/php/5.6/mods-available/xdebug.ini && \
  echo "xdebug.remote_autostart = 1" >> /etc/php/5.6/mods-available/xdebug.ini && \
  echo "xdebug.remote_connect_back = 0" >> /etc/php/5.6/mods-available/xdebug.ini && \
  echo "xdebug.profiler_enable = 0" >> /etc/php/5.6/mods-available/xdebug.ini && \
  echo "xdebug.remote_log = /tmp/xdebug.log" >> /etc/php/5.6/mods-available/xdebug.ini && \
  echo "xdebug.remote_host = 127.0.0.1" >> /etc/php/5.6/mods-available/xdebug.ini && \
  echo "xdebug.remote_port = 9001" >> /etc/php/5.6/mods-available/xdebug.ini
  
WORKDIR /var/www/html

# By default, simply start apache.
CMD ["/sbin/entrypoint.sh"]
