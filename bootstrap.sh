#!/bin/bash

# Enable DeltaRPMs
yum -y install yum-presto

# Add EPEL repository
yum -y install epel-release

# Ensure base system is up to date
#yum update -y

# Install required packages
# We can get most from the repos
yum install -y git php-pear sendmail htop httpd mysql-server php php-mysql php-cli vim php-xml screen rubygems php-pecl-memcache php-mbstring php-gd php-ldap phpmyadmin

# SASS
sudo gem install sass

# Copy our custom files over
cp -Rv /vagrant/skel/* /


# Configure MySQL + Apache
service httpd start
service mysqld start
# Set MySQL root password. Don't worry about security - this is inaccessible from outside.
/usr/bin/mysqladmin -u root password 'thisisasecurepassword'
chkconfig mysqld on
chkconfig httpd on

# Allow access to HTTP error logs by user vagrant
chown root:vagrant /var/log/httpd
chmod 770 /var/log/httpd
chmod 644 /var/log/httpd/*

# Clear all firewall rules
iptables --flush
service iptables save
service iptables restart

# Create the database
echo "Creating database..."
mysql -u root --password=thisisasecurepassword < /vagrant/create_database.sql

cd /vagrant/site/api
./propel-gen
./propel-gen insert-sql

# Restart apache just to be sure that the new config files were recognized...
service httpd restart
