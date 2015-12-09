#!/bin/bash

# Roundcube

# Remove Exim (default Debian)
apt-get remove -y exim4 exim4-base exim4-config exim4-daemon-light

# Install Postfix
echo "postfix postfix/mailname string ${POSTFIX_HOSTNAME}" | debconf-set-selections
echo "postfix postfix/myhostname string ${POSTFIX_HOSTNAME}" | debconf-set-selections
echo "postfix postfix/destinations string '${POSTFIX_HOSTNAME}, localhost'" | debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections

apt-get -y install postfix postfix-pcre

echo '/@.*/ vagrant@localhost' > /etc/postfix/virtual_forwardings.pcre
echo '/^.*/ OK' > /etc/postfix/virtual_domains.pcre

cat << EOF >>/etc/postfix/main.cf

virtual_alias_domains =
virtual_alias_maps = pcre:/etc/postfix/virtual_forwardings.pcre
virtual_mailbox_domains = pcre:/etc/postfix/virtual_domains.pcre
home_mailbox = Maildir/
EOF

sed -i 's/mailbox_command = .*/mailbox_command =/' /etc/postfix/main.cf
sed -i "s/myhostname = .*/myhostname = ${POSTFIX_HOSTNAME}/" /etc/postfix/main.cf

service postfix restart

# Install Dovecot
apt-get -y install dovecot-imapd
mkdir -p /home/vagrant/Maildir/{cur,new,tmp}
chown -R vagrant:vagrant /home/vagrant/Maildir
sed -i 's/^mail_location = .*/mail_location = maildir:~\/Maildir/' /etc/dovecot/conf.d/10-mail.conf
service dovecot restart

# Roundcube: download and extract
ROUNDCUBE_VERSION="1.1.2"
cd /var/www
wget http://downloads.sourceforge.net/project/roundcubemail/roundcubemail/${ROUNDCUBE_VERSION}/roundcubemail-${ROUNDCUBE_VERSION}-complete.tar.gz
tar xzvf roundcubemail-${ROUNDCUBE_VERSION}-complete.tar.gz
mv roundcubemail-${ROUNDCUBE_VERSION} roundcube
rm -rf roundcubemail-${ROUNDCUBE_VERSION}-complete.tar.gz
chown -R vagrant:vagrant roundcube
chmod -R ug+rwX roundcube

# Roundcube: configure
cd roundcube
mysql -uroot -pvagrant -e "CREATE DATABASE roundcubemail DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"
mysql -uroot -pvagrant -e "GRANT ALL PRIVILEGES ON roundcubemail.* TO roundcube@localhost IDENTIFIED BY 'cubepass';"
mysql -uroot -pvagrant roundcubemail < SQL/mysql.initial.sql
cp config/config.inc.php.sample config/config.inc.php
sed -i 's/pass@localhost/cubepass@localhost/g' config/config.inc.php
sed -i 's/larry/classic/' config/config.inc.php
echo '$config['show_images'] = 1;' >> config/config.inc.php
sed -i "s/'id' => 'rcmloginuser'/'id' => 'rcmloginuser', 'value' => 'vagrant'/" program/include/rcmail_output_html.php
sed -i "s/'id' => 'rcmloginpwd'/'id' => 'rcmloginpwd', 'value' => 'vagrant'/" program/include/rcmail_output_html.php

# Roundcube: add Nginx vhost
cat ${CONFIG_PATH}/apache/roundcube.vhost.conf > /etc/apache2/sites-available/roundcube.${APP_DOMAIN}.conf
a2ensite roundcube.${APP_DOMAIN}
service apache2 restart

# Install the mail command (for CLI debugging)
apt-get install -y mailutils

