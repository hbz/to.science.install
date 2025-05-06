#!/bin/bash

source variables.conf

if [ ! -d $ARCHIVE_HOME/git/to.science.forms ]
then
	git clone https://github.com/hbz/to.science.forms.git $ARCHIVE_HOME/git/to.science.forms 
fi

ln -s /etc/toscience/resources/labels.json /etc/toscience/forms/labels.json
cd $ARCHIVE_HOME/git/to.science.forms
git checkout origin/master
cp -r conf.tmpl/* /etc/toscience/forms/
rm /etc/toscience/forms/routes
ln -s $ARCHIVE_HOME/git/to.science.forms/conf.tmpl/routes /etc/toscience/forms/routes
cp $ARCHIVE_HOME/conf/application.forms.conf   /etc/toscience/forms/application.conf
cp $ARCHIVE_HOME/conf/forms.env    /etc/toscience/forms/env
ln -s /etc/toscience/forms/  conf
. bin/deploy.sh master
. bin/install.sh
