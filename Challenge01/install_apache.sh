#!/bin/bash
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
sudo chmod 775 /var/www/html
sudo echo "<h1>Deployed $(hostname) via Terraform</h1>" > /var/www/html/index.html