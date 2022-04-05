#!/bin/bash

source variables.conf

function copyConfig()
{
cp $ARCHIVE_HOME/conf/tomcat-users.xml $TOMCAT_CONF
cp $ARCHIVE_HOME/conf/fedora-users.xml $ARCHIVE_HOME/fedora/server/config/
cp $ARCHIVE_HOME/conf/fedora.fcfg $ARCHIVE_HOME/fedora/server/config/
cp $ARCHIVE_HOME/conf/setenv.sh $TOMCAT_HOME/bin
cp $ARCHIVE_HOME/conf/application.conf $ARCHIVE_HOME/toscience-server/conf
cp $ARCHIVE_HOME/conf/heritrix-start.sh $ARCHIVE_HOME/heritrix/
echo "Bitte führen Sie die folgenden Befehle manuell aus:"
echo "sudo cp $ARCHIVE_HOME/conf/elasticsearch.yml $ELASTICSEARCH_CONF"
echo "sudo cp $ARCHIVE_HOME/conf/toscience-api /etc/init.d"
echo "sudo chkconfig --set toscience-api on"
echo "sudo cp $ARCHIVE_HOME/conf/tomcat6 /etc/init.d"
echo "sudo chkconfig --set tomcat6 on"
}

copyConfig
