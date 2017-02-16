# mysql
sudo apt-get update -y
export DEBIAN_FRONTEND="noninteractive"
echo 'mysql-server mysql-server/root_password password password' | sudo debconf-set-selections
echo 'mysql-server mysql-server/root_password_again password password' | sudo debconf-set-selections
sudo apt-get -y install mysql-server
