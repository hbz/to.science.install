#!/bin/bash

source variables.conf

if [ ! -d $ARCHIVE_HOME/git/to.science.labels ]
then
	git clone https://github.com/hbz/to.science.labels.git $ARCHIVE_HOME/git/to.science.labels 
fi

ln -s /etc/toscience/resources/labels.json /etc/toscience/labels/labels.json
cd $ARCHIVE_HOME/git/to.science.labels
git checkout origin/main
cp -r conf.tmpl/* /etc/toscience/labels/
rm /etc/toscience/labels/routes
ln -s $ARCHIVE_HOME/git/to.science.labels/conf.tmpl/routes /etc/toscience/labels/routes
cp $ARCHIVE_HOME/conf/application.labels.conf   /etc/toscience/labels/application.conf
cp $ARCHIVE_HOME/conf/labels.env    /etc/toscience/labels/env
ln -s /etc/toscience/labels/  conf
. bin/deploy.sh main
. bin/install.sh
