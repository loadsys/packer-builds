# php 5.6

# Webservers supported by this script
# Nginx uses WEBSERVER=nginx
# Apache uses WEBSERVER=apache

[ "$WEBSERVER" = "nginx" ] && WEBPKG="php5.6-fpm" || WEBPKG="libapache2-mod-php5.6"

sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update -y
sudo apt-get install -y php5.6 $WEBPKG php5.6-curl php5.6-intl php5.6-mbstring php5.6-mcrypt php5.6-mysql php5.6-gd php5.6-xml php5.6-soap
