#!/bin/bash

# PHP

apt-get -y install php7.0-common php7.0-cli php7.0-fpm php7.0-dev php7.0-opcache php7.0-curl php7.0-intl \
    php7.0-mysql php7.0-sqlite3 php7.0-gd php7.0-mcrypt

sed -i 's/;date.timezone.*/date.timezone = Europe\/Brussels/' /etc/php/7.0/fpm/php.ini
sed -i 's/;date.timezone.*/date.timezone = Europe\/Brussels/' /etc/php/7.0/cli/php.ini
sed -i 's/^user = www-data/user = vagrant/' /etc/php/7.0/fpm/pool.d/www.conf
sed -i 's/^group = www-data/group = vagrant/' /etc/php/7.0/fpm/pool.d/www.conf

# xdebug
mkdir xdebug
cd xdebug
wget http://xdebug.org/files/xdebug-2.4.0rc2.tgz
tar -xvzf xdebug-2.4.0rc2.tgz
cd xdebug-2.4.0RC2
phpize
./configure
make
cp modules/xdebug.so /usr/lib/php/20151012
cd ..
rm -rf xdebug
echo "zend_extension=/usr/lib/php/20151012/xdebug.so" > /etc/php/7.0/mods-available/xdebug.ini
ln -s /etc/php/7.0/mods-available/xdebug.ini /etc/php/7.0/cli/conf.d/30-xdebug.ini
ln -s /etc/php/7.0/mods-available/xdebug.ini /etc/php/7.0/fpm/conf.d/30-xdebug.ini
cat << EOF >>/etc/php/7.0/mods-available/xdebug.ini
xdebug.remote_enable=1
xdebug.remote_autostart=1
xdebug.remote_host=192.168.33.1
xdebug.max_nesting_level=250
; xdebug.profiler_enable=1
; xdebug.profiler_output_dir=/vagrant/dumps
EOF

service php7.0-fpm restart

# composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin

# phpunit
wget -P /usr/bin https://phar.phpunit.de/phpunit.phar
chmod +x /usr/bin/phpunit.phar
ln -s /usr/bin/phpunit.phar /usr/bin/phpunit

