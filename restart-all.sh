#!/bin/bash 

source variables.conf

sudo systemctl restart mariadb.service
sudo systemctl restart elasticsearch.service
sudo systemctl restart fedora.service
sudo systemctl restart toscience-labels.service
sudo systemctl restart toscience-forms.service
sudo systemctl restart toscience-api.service
sudo systemctl restart apache2.service
sudo systemctl restart fph56-fpm.service

