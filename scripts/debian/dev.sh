## Install CakePHP development server extras

# PHP versions supported by this script
# PHP5.4 (debian 7.11) uses PHP_SUFFIX=5
# PHP5.6 (ubuntu 14.04) uses PHP_SUFFIX=5.6
# PHP7.0 (ubuntu 16.04) uses PHP_SUFFIX=


# dev related packages
[ "$PHP_SUFFIX" = "5" ] && PHP_SQLITE="php5-sqlite" || PHP_SQLITE="php${PHP_SUFFIX}-sqlite3"
sudo apt-get install -y libsqlite3-dev ${PHP_SQLITE} php${PHP_SUFFIX}-xdebug

# mysql
[ "$MYSQL_SUFFIX" = "5.6" ] && MYSQLPKG="mysql-server-5.6" || MYSQLPKG="mysql-server"
export DEBIAN_FRONTEND="noninteractive"
echo 'mysql-server mysql-server/root_password password password' | sudo debconf-set-selections
echo 'mysql-server mysql-server/root_password_again password password' | sudo debconf-set-selections
if [ "$MYSQL_SUFFIX" = "5.6" ]; then
	sudo apt-get -y install mysql-client-5.6 mysql-client-core-5.6
fi
sudo apt-get -y install $MYSQLPKG

# Stop MySQL server so we have memory for build cleanup
sudo service mysql stop

# memcached
sudo apt-get install -y memcached php${PHP_SUFFIX}-memcached

# - Configure memcached to listen on all interfaces (this is not safe for production).
sudo sed -i '/-l/c -l 0.0.0.0' /etc/memcached.conf
sudo service memcached restart

# enable installed php mods
[ "$PHP_SUFFIX" = "5" ] && PHP_ENMOD="php5enmod" || PHP_ENMOD="phpenmod"
sudo $PHP_ENMOD memcached sqlite3 pdo_sqlite xdebug
