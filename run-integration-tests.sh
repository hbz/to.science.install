#!/bin/bash

source variables.conf

cd $ARCHIVE_HOME/git/to.science.api
$ARCHIVE_HOME/activator/activator test
status=$?
cd -

exit $status
