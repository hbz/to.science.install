#!/bin/bash
#
# Authors: Jan Schnasse, Ingolf Kuss (hbz)

source variables.conf

function install()
{
echo "Install Elasticsearch"
./install-elasticsearch.sh
echo "Install Fedora"
./install-fedora.sh
echo "Install Heritrix"
./install-heritrix.sh
echo "Install Play2"
./install-play.sh > /dev/null 
echo "Install Tomcat"
./install-tomcat.sh
echo "Install toscience API"
./install-to.science-api.sh
}

install
