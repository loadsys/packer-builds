# setup
echo "UTC" | sudo tee /etc/timezone > /dev/null
sudo dpkg-reconfigure --frontend noninteractive tzdata

sudo apt-get install -y \
 software-properties-common \
 python-software-properties \
 build-essential \
 curl \
 bzip2 \
 gzip \
 unzip \
 zip \
 vim \
 mysql-client
