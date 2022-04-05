#! /bin/bash

source variables.conf

function makeDir()
{
if [ ! -d $1 ]
then
mkdir -v -p $1
fi
}
function makeDirs()
{
makeDir $ARCHIVE_HOME/sync
makeDir $ARCHIVE_HOME/fedora
makeDir $ARCHIVE_HOME/logs
makeDir $ARCHIVE_HOME/conf
makeDir $ARCHIVE_HOME/proai/cache
makeDir $ARCHIVE_HOME/proai/sessions
makeDir $ARCHIVE_HOME/proai/schemas
if [ ! -f $ARCHIVE_HOME/to.science.install/scripts/variables.conf ]
then
ln -s $ARCHIVE_HOME/to.science.install/variables.conf $ARCHIVE_HOME/to.science.install/scripts/variables.conf
fi
}

function createConfig()
{
substituteVars install.properties $ARCHIVE_HOME/conf/install.properties
substituteVars fedora-users.xml $ARCHIVE_HOME/conf/fedora-users.xml
substituteVars api.properties $ARCHIVE_HOME/conf/api.properties
substituteVars tomcat-users.xml $ARCHIVE_HOME/conf/tomcat-users.xml
substituteVars setenv.sh $ARCHIVE_HOME/conf/setenv.sh
substituteVars elasticsearch.yml $ARCHIVE_HOME/conf/elasticsearch.yml
substituteVars site.conf $ARCHIVE_HOME/conf/site.conf
substituteVars site.ssl.conf $ARCHIVE_HOME/conf/site.ssl.conf
substituteVars logging.properties $ARCHIVE_HOME/conf/logging.properties
substituteVars catalina.out $ARCHIVE_HOME/conf/catalina.out
substituteVars Identify.xml $ARCHIVE_HOME/conf/Identify.xml
substituteVars proai.properties $ARCHIVE_HOME/conf/proai.properties
substituteVars robots.txt $ARCHIVE_HOME/conf/robots.txt
substituteVars tomcat.conf $ARCHIVE_HOME/conf/tomcat.conf
substituteVars application.conf $ARCHIVE_HOME/conf/application.conf
substituteVars fedora.fcfg $ARCHIVE_HOME/conf/fedora.fcfg
substituteVars tomcat6 $ARCHIVE_HOME/conf/tomcat6
substituteVars toscience-api $ARCHIVE_HOME/conf/toscience-api
substituteVars heritrix-start.sh $ARCHIVE_HOME/conf/heritrix-start.sh
substituteVars heritrix $ARCHIVE_HOME/conf/heritrix

cp templates/favicon.ico $ARCHIVE_HOME/conf/favicon.ico
cp templates/datacite.cert $ARCHIVE_HOME/conf/datacite.cert

if [ ! -f $SSL_PRIVATE_KEY_BACKEND ]
then
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout  $SSL_PRIVATE_KEY_BACKEND -out  $SSL_PUBLIC_CERT_BACKEND -subj "/C=GE/ST=Berlin/L=Berlin/O=toscience/OU=repos/CN=$BACKEND"
fi

if [ ! -f $SSL_PRIVATE_KEY_FRONTEND ]
then
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout  $SSL_PRIVATE_KEY_FRONTEND -out  $SSL_PUBLIC_CERT_FRONTEND -subj "/C=GE/ST=Berlin/L=Berlin/O=toscience/OU=repos/CN=$FRONTEND"
fi

if [ ! -f $KEYSTORE ]
then
keytool -genkey -noprompt \
 -alias toscience \
 -dname "CN=$FRONTEND, OU=repos, O=toscience, L=BERLIN, S=BERLIN, C=GE" \
 -keystore $KEYSTORE \
 -storepass ${PASSWORD}123 \
 -keypass ${PASSWORD}123
fi

keytool -import -trustcacerts -alias to.science.drupal -file $SSL_PUBLIC_CERT_FRONTEND -storepass ${PASSWORD}123 -keypass ${PASSWORD}123 -keystore $KEYSTORE -noprompt

keytool -import -trustcacerts -alias to.science.api -file $SSL_PUBLIC_CERT_BACKEND  -storepass ${PASSWORD}123 -keypass ${PASSWORD}123 -keystore $KEYSTORE -noprompt

keytool -import -trustcacerts -alias datacite -file $ARCHIVE_HOME/conf/datacite.cert  -storepass ${PASSWORD}123 -keypass ${PASSWORD}123 -keystore $KEYSTORE -noprompt

keytool -list -alias heritrix -keystore $KEYSTORE -storepass ${PASSWORD}123 > /dev/null
if (($? == 0)); then
echo "Add new heritrix key!"
  keytool -keystore $KEYSTORE -storepass ${PASSWORD}123 -keypass ${PASSWORD}123 -alias heritrix -genkey -keyalg RSA -dname "CN=localhost" -validity 3650
fi

}

function substituteVars()
{
PLAY_SECRET=`uuidgen`
file=templates/$1
target=$2
ADMIN_HASH=`echo -n $ADMIN_SALT$PASSWORD | sha256sum | sed -e "s/  \-$//"`
sed -e "s,\$SERVER,$SERVER,g" \
-e "s,\$ADMIN_PASSWORD,$ADMIN_PASSWORD,g" \
-e "s,\$ADMIN_SALT,$ADMIN_SALT,g" \
-e "s,\$ADMIN_HASH,$ADMIN_HASH,g" \
-e "s,\$ADMIN_USER,$ADMIN_USER,g" \
-e "s,\$API_USER,$API_USER,g" \
-e "s,\$APACHE_LOGVERZ,$APACHE_LOGVERZ,g" \
-e "s,\$APACHE_ACCESS_LOGNAME,$APACHE_ACCESS_LOGNAME,g" \
-e "s,\$ARCHIVE_HOME,$ARCHIVE_HOME,g" \
-e "s,\$BACKEND,$BACKEND,g" \
-e "s,\$CRONJOBS_DIR,$CRONJOBS_DIR,g" \
-e "s,\$DATACITE_PASSWORD,$DATACITE_PASSWORD,g" \
-e "s,\$DATACITE_USER,$DATACITE_USER,g" \
-e "s,\$DOIPREFIX,$DOIPREFIX,g" \
-e "s,\$ELASTICSEARCH_CONF,$ELASTICSEARCH_CONF,g" \
-e "s,\$ELASTICSEARCH_PORT,$ELASTICSEARCH_PORT,g" \
-e "s,\$EMAIL,$EMAIL,g" \
-e "s,\$EMAIL_RECIPIENT_ADMIN_USERS,$EMAIL_RECIPIENT_ADMIN_USERS,g" \
-e "s,\$EMAIL_RECIPIENT_PROJECT_ADMIN,$EMAIL_RECIPIENT_PROJECT_ADMIN,g" \
-e "s,\$FEDORA_USER,$FEDORA_USER,g" \
-e "s,\$FRONTEND,$FRONTEND,g" \
-e "s,\$HERITRIX_DATA,$HERITRIX_DATA,g" \
-e "s,\$HERITRIX_DIR,$HERITRIX_DIR,g" \
-e "s,\$HERITRIX_URL,$HERITRIX_URL,g" \
-e "s,\$IP,$IP,g" \
-e "s,\$KEYSTORE,$KEYSTORE,g" \
-e "s,\$LINUX_GROUP,$LINUX_GROUP,g" \
-e "s,\$LINUX_USER,$LINUX_USER,g" \
-e "s%\$NAMESPACE%$NAMESPACE%g" \
-e "s,\$PASSWORD,$PASSWORD,g" \
-e "s,\$PLAYPORT,$PLAYPORT,g" \
-e "s,\$PLAY_SECRET,$PLAY_SECRET,g" \
-e "s,\$PROJECT,$PROJECT,g" \
-e "s,\$SSL_PUBLIC_CERT_BACKEND,$SSL_PUBLIC_CERT_BACKEND,g" \
-e "s,\$SSL_PRIVATE_KEY_BACKEND,$SSL_PRIVATE_KEY_BACKEND,g" \
-e "s,\$SSL_PUBLIC_CERT_FRONTEND,$SSL_PUBLIC_CERT_FRONTEND,g" \
-e "s,\$SSL_PRIVATE_KEY_FRONTEND,$SSL_PRIVATE_KEY_FRONTEND,g" \
-e "s,\$SSL_CHAIN_FRONTEND,$SSL_CHAIN_FRONTEND,g" \
-e "s,\$STATS_LOG,$STATS_LOG,g" \
-e "s,\$TMPDIR,$TMPDIR,g" \
-e "s,\$TMPLOGVERZ,$TMPLOGVERZ,g" \
-e "s,\$TOMCAT_CONF,$TOMCAT_CONF,g" \
-e "s,\$TOMCAT_HOME,$TOMCAT_HOME,g" \
-e "s,\$TOMCAT_PORT,$TOMCAT_PORT,g" \
-e "s,\$URNBASE,$URNBASE,g" \
-e "s,\$URNSNID,$URNSNID,g" \
-e "s,\$VERSION,$VERSION,g" \
-e "s,\$WHITELIST,$WHITELIST,g" $file > $target
}

makeDirs
createConfig
