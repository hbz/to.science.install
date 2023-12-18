#!/bin/bash

echo "Install Elasticsearch"
echo "WARNING: if Elasticsearch is already installed the next command will"
echo "force to install 1.1.0"
echo "Please press cntrl+C to abort"


# Add Repo
  zypper ar -f http://packages.elastic.co/elasticsearch/1.1/centos Elasticsearch_1.1_repository
# Import key
  zypper --gpg-auto-import-keys ref
  zypper in --oldpackage elasticsearch-1.1.0-1.noarch

# Install Elasticsearch Head Plugin
 cd /usr/share/elasticsearch/bin
 sudo su
 ./plugin -install mobz/elasticsearch-head/
 # install further elasticsearch plugins
 ## Plugin analysis-icu
 cd /usr/share/elasticsearch/plugins
 mkdir analysis-icu
 cd analysis-icu
 wget -4 http://download.elasticsearch.org/elasticsearch/elasticsearch-analysis-icu/elasticsearch-analysis-icu-2.1.0.zip
 unzip elasticsearch-analysis-icu-2.1.0.zip

  ## Plugin analysis-combo
  cd /usr/share/elasticsearch/plugins
  mkdir analysis-combo
  cd analysis-combo
  wget -4 https://repo1.maven.org/maven2/com/yakaz/elasticsearch/plugins/elasticsearch-analysis-combo/1.5.1/elasticsearch-analysis-combo-1.5.1.zip
  unzip elasticsearch-analysis-combo-1.5.1.zip

echo "Start Elasticsearch"
  systemctl start elasticsearch.service
