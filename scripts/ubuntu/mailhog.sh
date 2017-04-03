#!/usr/bin/env bash

# Get latest release
LATEST_URL=$(curl -s https://api.github.com/repos/mailhog/MailHog/releases | grep browser_download_url | grep 'linux_amd64' | head -n 1 | cut -d '"' -f 4)

# Download binary from github
sudo wget --quiet -O ~/mailhog $LATEST_URL

# Make it executable
chmod +x ~/mailhog

# Make it start on reboot
sudo tee /etc/systemd/system/mailhog.service <<EOL
[Unit]
Description=MailHog Service
After=network.service vagrant.mount
[Service]
Type=simple
ExecStart=/usr/bin/env /home/vagrant/mailhog > /dev/null 2>&1 &
[Install]
WantedBy=multi-user.target
EOL

# Start on reboot
sudo systemctl enable mailhog

# Start background service now
sudo systemctl start mailhog
