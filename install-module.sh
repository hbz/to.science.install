#!/bin/bash

source variables.conf

function buildModule
{
cd $SRC
mvn install -DskipTests >> $ARCHIVE_HOME/logs/regal-build.log
cd -
echo "Generate Module $MODULE, templates can be found in $ARCHIVE_HOME/sync"
cd $SRC/${MODULE}-sync
mvn -q -e assembly:assembly -DskipTests >> $ARCHIVE_HOME/logs/regal-build.log
cd - 
}

function substituteVars()
{
file=templates/$1
target=$2
sed -e "s,\$ARCHIVE_HOME,$ARCHIVE_HOME,g" \
-e "s,\${NAMESPACE},$NAMESPACE,g" $file > $target
}

function buildStartScript
{
substituteVars sync.sh $ARCHIVE_HOME/sync/${NAMESPACE}Sync.sh.tmpl
}

function copy
{
cp $SYNCER_SRC $SYNCER_DEST
cp $MODULE_CONF $ARCHIVE_HOME/sync/${NAMESPACE}Variables.conf.tmpl
echo -e "TOMCAT_PORT=$TOMCAT_PORT\nSERVER=$SERVER\nBACKEND=$BACKEND" >>  $ARCHIVE_HOME/sync/${NAMESPACE}Variables.conf.tmpl
}

MODULE_CONF=$1
source $MODULE_CONF
SRC=$ARCHIVE_HOME/regal-import
SYNCER_SRC=$SRC/${MODULE}-sync/target/${MODULE}sync.jar
SYNCER_DEST=$ARCHIVE_HOME/sync/${MODULE}sync.jar


buildModule
buildStartScript
copy
