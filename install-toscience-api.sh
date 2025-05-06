#!/bin/bash

source variables.conf


if [ ! -d $ARCHIVE_HOME/git/to.science.api ]
then
	git clone https://github.com/hbz/to.science.api.git $ARCHIVE_HOME/git/to.science.api 
fi

ln -s /etc/toscience/resources/labels.json /etc/toscience/api/labels.json
ln -s /etc/toscience/resources/wglcontributor.csv /etc/toscience/api/wglcontributor.csv
cd $ARCHIVE_HOME/git/to.science.api
git checkout origin/main
cp -r conf.tmpl/* /etc/toscience/api/
rm /etc/toscience/api/routes
ln -s $ARCHIVE_HOME/git/to.science.api/conf.tmpl/routes /etc/toscience/api/routes
cp $ARCHIVE_HOME/conf/application.conf   /etc/toscience/api/
cp $ARCHIVE_HOME/conf/mail.properties    /etc/toscience/api/
cp $ARCHIVE_HOME/conf/application.env    /etc/toscience/api/env
ln -s /etc/toscience/api/  conf
. bin/deploy.sh main
. bin/install.sh
