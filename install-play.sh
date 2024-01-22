#!/bin/bash

source variables.conf


if [ -f typesafe-activator-1.3.5.zip ]
then
	echo "Activator is already here! Stop downloading!"
else
	wget http://downloads.typesafe.com/typesafe-activator/1.3.5/typesafe-activator-1.3.5.zip
fi

if [ -d $ARCHIVE_HOME/activator-1.3.5 ]
then
	echo "Activator already installed!"
else
	unzip typesafe-activator-1.3.5.zip -d $ARCHIVE_HOME 
fi

if [ -L $ARCHIVE_HOME/activator ]
then
	rm $ARCHIVE_HOME/activator
fi
ln -s $ARCHIVE_HOME/activator-dist-1.3.5 $ARCHIVE_HOME/activator
