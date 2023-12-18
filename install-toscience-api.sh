#!/bin/bash

source variables.conf


if [ ! -d $ARCHIVE_HOME/git/to.science.api ]
then
git clone https://github.com/hbz/to.science.api.git $ARCHIVE_HOME/git/to.science.api 
fi
# if [ ! -d $ARCHIVE_HOME/to.science.import ]
# then
# git clone https://github.com/hbz/regal-import.git $ARCHIVE_HOME/to.science.import
# fi

cd $ARCHIVE_HOME/git/to.science.api
# Branch auswählen
. bin/deploy.sh master-sles
. bin/install.sh
