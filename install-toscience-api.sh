#!/bin/bash

source variables.conf


if [ ! -d $ARCHIVE_HOME/git/to.science.api ]
then
	git clone https://github.com/hbz/to.science.api.git $ARCHIVE_HOME/git/to.science.api 
fi

cd $ARCHIVE_HOME/git/to.science.api
ln -s conf.tmpl/routes /etc/toscience/api/routes
. bin/deploy.sh master-sles
. bin/install.sh
