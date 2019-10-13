#--------------------------------------------------------------------------
# Image Setup
#--------------------------------------------------------------------------

FROM phpdockerio/php73-fpm:latest
WORKDIR "/application"

LABEL maintainer="Nassim Afrete <nassim.afrete@gmail.com>"

# Fix debconf warnings upon build
ARG DEBIAN_FRONTEND=noninteractive

# Install selected extensions and other stuff
RUN apt-get update \
    && apt-get -y --no-install-recommends install php7.3-intl php-mongodb php7.3-phpdbg php-yaml \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Install git
RUN apt-get update \
    && apt-get -y install git \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*


###########################################################################
# Check PHP version:
###########################################################################

RUN set -xe; php -v | head -n 1 | grep -q "PHP 7.3."

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#

COPY ./php.ini /usr/local/etc/php/conf.d
COPY ./pool.conf /usr/local/etc/php-fpm.d/

USER root

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

RUN usermod -u 1000 www-data

CMD ["php-fpm"]

EXPOSE 9000