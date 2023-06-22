#! /bin/bash

source variables.conf


if [ ! -d $ARCHIVE_HOME/to.science.api ]
then
git clone https://github.com/hbz/to.science.api.git $ARCHIVE_HOME/to.science.api 
fi
if [ ! -d $ARCHIVE_HOME/to.science.import ]
then
git clone https://github.com/edoweb/regal-import.git $ARCHIVE_HOME/to.science.import
fi

cd $ARCHIVE_HOME/to.science.api
# Branch auswählen
git pull origin master
/opt/activator/activator clean
/opt/activator/activator clean-files
/opt/activator/activator dist
cd -

cd $ARCHIVE_HOME

OLDDIR=`readlink regal-server`
CONF=`readlink $OLDDIR/conf`
OLDPORT=`grep "http.port" $CONF/application.conf | grep -o "[0-9]*"`

if [ $OLDPORT -eq 9000 ]
then
PLAYPORT=9100
else
PLAYPORT=9000
fi


unzip to.science.api/target/universal/regal-api-*zip -d tmp >/dev/null 
regalServerDir=regal-server.`date  +"%Y%m%d%H%M"`
mv tmp/regal-api* $regalServerDir
rm -rf tmp
sed -e "s/^http\.port=.*$/http\.port=$PLAYPORT/" $CONF/application.conf > /tmp/application.conf
mv /tmp/application.conf $CONF/application.conf
rm -r $regalServerDir/conf
ln -s $CONF $regalServerDir/conf
rm $ARCHIVE_HOME/regal-server
ln -s $regalServerDir $ARCHIVE_HOME/regal-server

echo ""
echo "New executable available under $regalServerDir." 
echo "Provided port info at $CONF/application.conf." 
echo "Ready to switch from $OLDDIR to $regalServerDir. From old port $OLDPORT to new $PLAYPORT"
echo "monit has automatically started the new executable under port $PLAYPORT. Check this with \"ps -eaf | grep regal-server\""
echo "(if you do not want monit to start the new executable automatically, you should have done \"monit unmonitor regal-api\" before you started this script)"
echo "If the new executable should not yet be running, try to start it with \"sudo service regal-api start\""
echo ""
echo "To perform switch, update the port information in your apache conf to $PLAYPORT!" 
echo "cp ../prod_conf/site.ssl.conf ../prod_conf/site.ssl.conf.bck ; cat ../prod_conf/site.ssl.conf|sed s/"$OLDPORT"/"$PLAYPORT"/g >tmp; mv tmp ../prod_conf/site.ssl.conf"
echo "sudo service apache2 reload"
echo "kill `cat $OLDDIR/RUNNING_PID`"
echo ""
echo "Refresh Cache:"
echo "./loadCache.sh"

cd -
