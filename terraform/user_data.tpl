#!/bin/bash

# Install LAMP Server
yum update -y
yum install -y httpd
yum install -y mariadb-server

# Start and enable MariaDB service
systemctl start mariadb
systemctl enable mariadb

# Run mysql_secure_installation to set root password and secure installation
mysql_secure_installation <<EOF

y
root_password
root_password
y
y
y
y
EOF

# Create database and user for WordPress
mysql -u root -proot_password <<EOF
CREATE DATABASE ${db_name};
CREATE USER '${db_user}'@'localhost' IDENTIFIED BY '${db_password}';
GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user}'@'localhost';
FLUSH PRIVILEGES;
EXIT;
EOF

amazon-linux-extras enable php8.2
yum clean metadata
yum install -y php php-{pear,cgi,common,curl,mbstring,gd,mysqlnd,gettext,bcmath,json,xml,fpm,intl,zip,imap,devel}
yum -y install gcc ImageMagick ImageMagick-devel ImageMagick-perl
pecl install imagick
chmod 755 /usr/lib64/php/modules/imagick.so
cat <<EOF >>/etc/php.d/20-imagick.ini

extension=imagick

EOF

systemctl restart php-fpm.service
systemctl start httpd

# Install wget
yum install -y wget

# Download phpMyAdmin
cd /var/www/html
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz

# Extract phpMyAdmin
tar -xvf phpMyAdmin-latest-all-languages.tar.gz
mv phpMyAdmin-*-all-languages phpmyadmin
rm phpMyAdmin-latest-all-languages.tar.gz

# Configure Apache to serve phpMyAdmin
cat << EOF > /etc/httpd/conf.d/phpmyadmin.conf
Alias /phpmyadmin /var/www/html/phpmyadmin

<Directory /var/www/html/phpmyadmin>
    Require all granted
</Directory>
EOF

# Restart Apache to apply changes
systemctl restart httpd

# Change owner and permissions of /var/www/ folder
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;

# Change permission of /var/www/html/
chown -R ec2-user:apache /var/www/html
chmod -R 774 /var/www/html

# Enable .htaccess files in Apache config using sed command
sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride all/' /etc/httpd/conf/httpd.conf

# Make apache autostart and restart apache
systemctl enable  httpd.service
systemctl restart httpd.service

# ===============================
# SSL CERTIFICATE INSTALLATION WITH CERTBOT
# ===============================
# Install EPEL and Certbot
amazon-linux-extras install epel
yum install -y certbot python2-certbot-apache
certbot --version

# Obtain the SSL certificate (replace with your domain name)
certbot --apache -n --agree-tos --email ${certbot_email} --redirect -d ${certbot_domain}

# Set up automatic certificate renewal (Certbot renews automatically via a cron job)
echo "0 12 * * * /usr/bin/certbot renew --quiet" > /etc/cron.d/certbot-renew

# ===============================
# ENABLE SFTP FOR UPLOADS
# ===============================
# SFTP is enabled by default on Amazon Linux (via SSH). Just make sure the ec2-user has the right permissions.

# Allow password authentication in sshd config (optional, if needed)
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Restart SSH service to apply changes
systemctl restart sshd

# Ensure ec2-user can use SFTP
usermod -aG apache ec2-user
chown -R ec2-user:apache /var/www/html

