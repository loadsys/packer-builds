# dev related packages
sudo apt-get install -y libsqlite3-dev php${PHP_SUFFIX}-sqlite php${PHP_SUFFIX}-xdebug

# mysql
export DEBIAN_FRONTEND="noninteractive"
echo 'mysql-server mysql-server/root_password password password' | sudo debconf-set-selections
echo 'mysql-server mysql-server/root_password_again password password' | sudo debconf-set-selections
sudo apt-get -y install mysql-server

# memcached
sudo apt-get install -y memcached php${PHP_SUFFIX}-memcached

# - Configure memcached to listen on all interfaces (this is not safe for production).
sudo sed -i '/-l/c -l 0.0.0.0' /etc/memcached.conf
sudo service memcached restart

# enable installed php mods
[ $PHP_SUFFIX = "5" ] && PHP_ENMOD="php5enmod" || PHP_ENMOD="phpenmod"
sudo $PHP_ENMOD memcached sqlite3 pdo_sqlite xdebug
