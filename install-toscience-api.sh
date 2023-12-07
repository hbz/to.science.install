#! /bin/bash

source variables.conf


if [ ! -d $ARCHIVE_HOME/src/to.science.api ]
then
git clone https://github.com/hbz/to.science.api.git $ARCHIVE_HOME/src/to.science.api 
fi
if [ ! -d $ARCHIVE_HOME/to.science.import ]
then
git clone https://github.com/hbz/regal-import.git $ARCHIVE_HOME/to.science.import
fi

cd $ARCHIVE_HOME/src/to.science.api
# Branch auswählen
git pull origin master-sles
$ARCHIVE_HOME/activator/activator clean
$ARCHIVE_HOME/activator/activator clean-files
$ARCHIVE_HOME/activator/activator dist
cd -

cd $ARCHIVE_HOME

OLDDIR=`readlink toscience-api`
CONF=`readlink $OLDDIR/conf`
OLDPORT=`grep "http.port" $CONF/application.conf | grep -o "[0-9]*"`

if [ $OLDPORT -eq 9000 ]
then
PLAYPORT=9100
else
PLAYPORT=9000
fi



unzip src/to.science.api/target/universal/toscience-api-*zip -d src/tmp >/dev/null 
toscienceServerDir=toscience-api.`date  +"%Y%m%d%H%M"`
mv src/tmp/toscience-api* $toscienceServerDir
rm -rf src/tmp
sed -e "s/^http\.port=.*$/http\.port=$PLAYPORT/" /etc/toscience/conf/application.conf > $toscienceServerDir/conf/application.conf
#cp toscience-server/conf/mail.properties $toscienceServerDir/conf/
rm $ARCHIVE_HOME/toscience-server
ln -s $toscienceServerDir $ARCHIVE_HOME/toscience-server

echo ""
echo "New executable available under $toscienceServerDir." 
echo "Provide port info at $toscienceServerDir/conf/application.conf." 
echo "Current port is set to $PLAYPORT"
echo "Ready to switch from $OLDDIR to $NEWDIR. From old port $OLDPORT to new $PLAYPORT"
echo ""
echo "Please update port information in your apache conf to $PLAYPORT!" 
echo "cp ../conf/site.ssl.conf ../conf/site.ssl.conf.bck ; cat ../conf/site.ssl.conf|sed s/"$OLDPORT"/"$PLAYPORT"/g >tmp; mv tmp ../conf/site.ssl.conf"
echo "To perform switch, execute:"  
echo "sudo service toscience-api start"
echo "./loadCache.sh"
echo "sudo service apache2 reload"
echo "kill `cat $OLDDIR/RUNNING_PID`"
echo ""
echo "Refresh Cache:"
echo "./loadCache.sh"

cd -
