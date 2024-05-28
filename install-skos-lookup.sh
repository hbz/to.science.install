#!/bin/bash

source variables.conf


if [ ! -d $ARCHIVE_HOME/git/skos-lookup ]
then
	git clone https://github.com/hbz/skos-lookup.git $ARCHIVE_HOME/git/skos-lookup
fi

# Prepare conf dir
if [ ! -d /etc/toscience/skos-lookup ]
then
	mkdir /etc/toscience/skos-lookup
fi
cd $ARCHIVE_HOME/git/skos-lookup
git checkout origin/master
cp conf.tmpl/application.conf /etc/toscience/skos-lookup/
cd /etc/toscience/skos-lookup
ln -s $ARCHIVE_HOME/git/skos-lookup/conf.tmpl/logback.xml
ln -s $ARCHIVE_HOME/git/skos-lookup/conf.tmpl/routes
ln -s $ARCHIVE_HOME/git/skos-lookup/conf.tmpl/skos-context.json
ln -s $ARCHIVE_HOME/git/skos-lookup/conf.tmpl/skos-settings.json
cp $ARCHIVE_HOME/conf/skos-lookup.env /etc/toscience/skos-lookup/env
cd $ARCHIVE_HOME/git/skos-lookup
ln -s /etc/toscience/skos-lookup/ conf
. bin/deploy.sh master
. bin/install.sh
