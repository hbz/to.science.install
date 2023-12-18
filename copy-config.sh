#!/bin/bash

source variables.conf

function copyConfig()
{
cp $ARCHIVE_HOME/conf/fedora.install.properties $ARCHIVE_HOME/fedora/install/install.properties
cp $ARCHIVE_HOME/conf/fedora-users.xml          $ARCHIVE_HOME/fedora/server/config/
cp $ARCHIVE_HOME/conf/fedora.fcfg               $ARCHIVE_HOME/fedora/server/config/
cp $ARCHIVE_HOME/conf/tomcat.setenv.sh          $TOMCAT_HOME/bin/setenv.sh
cp $ARCHIVE_HOME/conf/tomcat-users.xml          $TOMCAT_CONF/
cp $ARCHIVE_HOME/conf/tomcat.logging.properties $TOMCAT_CONF/logging.properties
cp $ARCHIVE_HOME/conf/proai.properties          $TOMCAT_HOME/webapps/oai-pmh/WEB-INF/classes/
cp $ARCHIVE_HOME/conf/application.conf   /etc/toscience/api/
cp $ARCHIVE_HOME/conf/application.env    /etc/toscience/api/env
cp $ARCHIVE_HOME/conf/application.labels.conf /etc/toscience/labels/application.conf
cp $ARCHIVE_HOME/conf/application.forms.conf  /etc/toscience/forms/application.conf
cp $ARCHIVE_HOME/conf/heritrix-start.sh $ARCHIVE_HOME/heritrix/
cp $ARCHIVE_HOME/conf/Identify.xml $ARCHIVE_HOME/drupal/oai/pmh/
#cp $ARCHIVE_HOME/conf/robots.txt $ARCHIVE_HOME/python3/lib/python3.6/site-packages/wpull/testing/static/
echo "Bitte führen Sie die folgenden Befehle manuell aus:"
echo "sudo cp $ARCHIVE_HOME/conf/elasticsearch.yml $ELASTICSEARCH_CONF"
echo "sudo cp $ARCHIVE_HOME/conf/toscience-api.service /etc/systemd/system/"
echo "sudo cp $ARCHIVE_HOME/conf/toscience-labels.service /etc/systemd/system/"
echo "sudo cp $ARCHIVE_HOME/conf/toscience-forms.service /etc/systemd/system/"
echo "sudo cp $ARCHIVE_HOME/conf/heritrix.service /etc/systemd/system/"
echo "sudo cp $ARCHIVE_HOME/conf/tomcat.service /etc/systemd/system"
echo "sudo systemctl enable toscience-api"
echo "sudo systemctl enable toscience-labels"
echo "sudo systemctl enable toscience-forms"
echo "sudo systemctl enable heritrix"
echo "sudo systemctl enable tomcat"
echo "sudo ln -s $ARCHVIE_HOME/conf/site.ssl.conf /etc/apache2/vhosts.d/site.ssl.conf"
echo "sudo ln -s $ARCHVIE_HOME/conf/wayback.$DOMAIN.conf /etc/apache2/vhosts.d/wayback.$DOMAIN.conf"
}

copyConfig
