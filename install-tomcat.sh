#!/bin/bash

sudo zypper in tomcat tomcat-admin-webapps
sudo systemctl start tomcat.service
