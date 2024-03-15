#!/bin/bash

source variables.conf

function sudoCopyConfig()
{
 cp $ARCHIVE_HOME/conf/elasticsearch.yml $ELASTICSEARCH_CONF
 cp $ARCHIVE_HOME/conf/toscience-api.service /etc/systemd/system/
 cp $ARCHIVE_HOME/conf/toscience-labels.service /etc/systemd/system/
 cp $ARCHIVE_HOME/conf/toscience-forms.service /etc/systemd/system/
 cp $ARCHIVE_HOME/conf/tomcat.service /etc/systemd/system/
 cp $ARCHIVE_HOME/conf/elasticsearch.service /etc/systemd/system/
 cp $ARCHIVE_HOME/conf/heritrix.service /etc/systemd/system/
 systemctl enable toscience-api
 systemctl enable toscience-labels
 systemctl enable toscience-forms
 systemctl enable tomcat
 systemctl enable elasticsearch
 systemctl enable heritrix
 ln -s $ARCHIVE_HOME/conf/site.ssl.conf /etc/apache2/vhosts.d/site.ssl.conf
 ln -s $ARCHIVE_HOME/conf/wayback.$DOMAIN.conf /etc/apache2/vhosts.d/wayback.$DOMAIN.conf
}

sudoCopyConfig
