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
OLDPORT=`grep "http.port" $OLDDIR/conf/application.conf | grep -o "[0-9]*"`

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
sed -e "s/^http\.port=.*$/http\.port=$PLAYPORT/" regal-server/conf/application.conf > $regalServerDir/conf/application.conf
cp regal-server/conf/mail.properties $regalServerDir/conf/
rm $ARCHIVE_HOME/regal-server
ln -s $regalServerDir $ARCHIVE_HOME/regal-server

echo ""
echo "New executable available under $regalServerDir." 
echo "Provide port info at $regalServerDir/conf/application.conf." 
echo "Current port is set to $PLAYPORT"
echo "Ready to switch from $OLDDIR to $NEWDIR. From old port $OLDPORT to new $PLAYPORT"
echo ""
echo "Please update port information in your apache conf to $PLAYPORT!" 
echo "cp ../prod_conf/site.ssl.conf ../prod_conf/site.ssl.conf.bck ; cat ../prod_conf/site.ssl.conf|sed s/"$OLDPORT"/"$PLAYPORT"/g >tmp; mv tmp ../prod_conf/site.ssl.conf"
echo "To perform switch, execute:"  
# echo "sudo service regal-api start" # monit startet den neuen Dienst schon automatisch
echo "./loadCache.sh"
echo "sudo service apache2 reload"
echo "kill `cat $OLDDIR/RUNNING_PID`"

cd -
