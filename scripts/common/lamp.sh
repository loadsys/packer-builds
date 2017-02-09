# base
sudo apt-get -y install vim git

# apache
sudo apt-get -y install apache2

# mysql
export DEBIAN_FRONTEND="noninteractive"
echo 'mysql-server mysql-server/root_password password password' | sudo debconf-set-selections
echo 'mysql-server mysql-server/root_password_again password password' | sudo debconf-set-selections
sudo apt-get -y install mysql-server

# php 5
sudo apt-get -y install php5 php5-curl php5-mcrypt php5-mysql php5-gd
