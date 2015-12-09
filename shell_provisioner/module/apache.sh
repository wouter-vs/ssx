#!/bin/bash

# Apache

apt-get install -y apache2 libapache2-mod-fcgid

a2enmod rewrite expires headers proxy proxy_fcgi actions fastcgi alias

a2dissite 000-default
echo "ServerTokens Prod" >>/etc/apache2/apache2.conf
echo "TraceEnable Off" >>/etc/apache2/apache2.conf
echo "FileETag None" >>/etc/apache2/apache2.conf

chmod -R a+rX /var/log/apache2
sed -i 's/640/666/' /etc/logrotate.d/apache2
sed -i 's/Listen /Listen '${GUEST_IP}':/' /etc/apache2/ports.conf

cat ${CONFIG_PATH}/apache/app.vhost.conf > /etc/apache2/sites-available/${APP_DOMAIN}.conf

a2ensite ${APP_DOMAIN}.conf
service apache2 restart

