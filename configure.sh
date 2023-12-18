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
makeDir $ARCHIVE_HOME/apps
makeDir $ARCHIVE_HOME/backups
makeDir $ARCHIVE_HOME/backups/elasticsearch
makeDir $ARCHIVE_HOME/backups/mysql
makeDir $ARCHIVE_HOME/conf
makeDir $ARCHIVE_HOME/crawlreports
makeDir $ARCHIVE_HOME/drupal/oai/pmh
makeDir $ARCHIVE_HOME/fedora
makeDir $ARCHIVE_HOME/logs
makeDir $ARCHIVE_HOME/tmp
if [ ! -f $ARCHIVE_HOME/git/to.science.install/scripts/variables.conf ]; then
  ln -s $ARCHIVE_HOME/git/to.science.install/variables.conf $ARCHIVE_HOME/git/to.science.install/scripts/variables.conf
fi
}

function createConfig()
{
export API_SECRET=`uuidgen`
export LABELS_SECRET=`uuidgen`
export FORMS_SECRET=`uuidgen`
export ADMIN_HASH=`echo -n ${ADMIN_SALT}${PASSWORD} | sha256sum | sed -e "s/  \-$//"`
export DATETIME=`date "+%Y-%m-%dT%H:%M:%SZ"`
substituteVars api.properties $ARCHIVE_HOME/conf/api.properties
substituteVars application.conf        $ARCHIVE_HOME/conf/application.conf
substituteVars application.env         $ARCHIVE_HOME/conf/application.env
substituteVars application.labels.conf $ARCHIVE_HOME/conf/application.labels.conf
substituteVars application.forms.conf  $ARCHIVE_HOME/conf/application.forms.conf
substituteVars elasticsearch.yml $ARCHIVE_HOME/conf/elasticsearch.yml
substituteVars fedora.install.properties $ARCHIVE_HOME/conf/fedora.install.properties
substituteVars fedora.fcfg $ARCHIVE_HOME/conf/fedora.fcfg
substituteVars fedora-users.xml $ARCHIVE_HOME/conf/fedora-users.xml
substituteVars heritrix-start.sh $ARCHIVE_HOME/conf/heritrix-start.sh
substituteVars heritrix.service $ARCHIVE_HOME/conf/heritrix.service
substituteVars Identify.xml $ARCHIVE_HOME/conf/Identify.xml
substituteVars proai.properties $ARCHIVE_HOME/conf/proai.properties
substituteVars robots.txt $ARCHIVE_HOME/conf/robots.txt
substituteVars tomcat.setenv.sh $ARCHIVE_HOME/conf/tomcat.setenv.sh
substituteVars tomcat.logging.properties $ARCHIVE_HOME/conf/tomcat.logging.properties
substituteVars site.conf $ARCHIVE_HOME/conf/site.conf
substituteVars site.ssl.conf $ARCHIVE_HOME/conf/site.ssl.conf
substituteVars wayback.ssl.conf $ARCHIVE_HOME/conf/wayback.$DOMAIN.conf
substituteVars tomcat.service $ARCHIVE_HOME/conf/tomcat.service
substituteVars tomcat-users.xml $ARCHIVE_HOME/conf/tomcat-users.xml
substituteVars tomcat.conf $ARCHIVE_HOME/conf/tomcat.conf
substituteVars toscience-api.service $ARCHIVE_HOME/conf/toscience-api.service
substituteVars toscience-labels.service $ARCHIVE_HOME/conf/toscience-labels.service
substituteVars toscience-forms.service $ARCHIVE_HOME/conf/toscience-forms.service

cp templates/favicon.ico $ARCHIVE_HOME/conf/favicon.ico
cp templates/datacite.cert $ARCHIVE_HOME/conf/datacite.cert

# Erzeugt ein selbstsigniertes Zertifikat und einen privaten Schlüssel für das Backend (API)
# Quelle: https://linuxconfig.org/how-to-generate-a-self-signed-ssl-certificate-on-linux
# zweite Quelle:  https://superuser.com/questions/1160382/how-to-pass-arguments-like-country-name-to-openssl-when-creating-self-signed-c
openssl req -x509 -newkey rsa:4096 -sha512 -days 365 -nodes -out $SSL_PUBLIC_CERT_BACKEND -keyout $SSL_PRIVATE_KEY_BACKEND -subj "/C=$SSL_PUBLIC_CERT_COUNTRY/ST=$SSL_PUBLIC_CERT_STATE/L=$SSL_PUBLIC_CERT_LOCATION/O=$SSL_PUBLIC_CERT_ORGANIZATION/OU=$SSL_PUBLIC_CERT_ORGANIZATION_UNIT/CN=api.$DOMAIN"

# Erzeugt ein selbstsigniertes Zertifikat und einen privaten Schlüssel für das Frontend (Drupal)
openssl req -x509 -newkey rsa:4096 -sha512 -days 365 -nodes -out $SSL_PUBLIC_CERT_FRONTEND -keyout $SSL_PRIVATE_KEY_FRONTEND -subj "/C=$SSL_PUBLIC_CERT_COUNTRY/ST=$SSL_PUBLIC_CERT_STATE/L=$SSL_PUBLIC_CERT_LOCATION/O=$SSL_PUBLIC_CERT_ORGANIZATION/OU=$SSL_PUBLIC_CERT_ORGANIZATION_UNIT/CN=$DOMAIN"

if [ -f $KEYSTORE ]; then
    rm $KEYSTORE
fi
# Erzeugt einen neuen Schlüsselspeicher
# Quelle: https://stackoverflow.com/questions/47434877/how-to-generate-keystore-and-truststore
# 1. Schlüsselspeicher generieren (auf dem Server):
keytool -genkey -storetype pkcs12 -noprompt -alias toscience -keyalg RSA -keysize 4096 -dname "C=$SSL_PUBLIC_CERT_COUNTRY, ST=$SSL_PUBLIC_CERT_STATE, L=$SSL_PUBLIC_CERT_LOCATION, O=$SSL_PUBLIC_CERT_ORGANIZATION, OU=$SSL_PUBLIC_CERT_ORGANIZATION_UNIT, CN=$DOMAIN" -keystore $KEYSTORE -storepass $STOREPASS -keypass $KEYPASS

# 2. Importiert das selbstsignierte Zertifikat für das Backend in den Schlüsselspeicher:
keytool -import -trustcacerts -noprompt -alias to.science.api -file $SSL_PUBLIC_CERT_BACKEND -keystore $KEYSTORE -storepass $STOREPASS -keypass $KEYPASS

# 3. Importiert das selbstsignierte Zertifikat für das Frontend in den Schlüsselspeicher:
keytool -import -trustcacerts -noprompt -alias to.science.drupal -file $SSL_PUBLIC_CERT_FRONTEND -keystore $KEYSTORE -storepass $STOREPASS -keypass $KEYPASS

# Importiert ein (abgelaufenes) Zertifikat für Datacite in den Schlüsselspeicher:
# keytool -import -trustcacerts -noprompt -alias datacite -file $ARCHIVE_HOME/conf/datacite.cert -keystore $KEYSTORE -storepass $STOREPASS -keypass $KEYPASS

# Importiert ein Zertifikat für heritrix in den Schlüsselspeicher:
keytool -genkey -storetype pkcs12 -noprompt -alias heritrix -keyalg RSA -keysize 4096 -dname "C=$SSL_PUBLIC_CERT_COUNTRY, ST=$SSL_PUBLIC_CERT_STATE, L=$SSL_PUBLIC_CERT_LOCATION, O=$SSL_PUBLIC_CERT_ORGANIZATION, OU=$SSL_PUBLIC_CERT_ORGANIZATION_UNIT, CN=$HERITRIX_URL" -validity 3650 -keystore $KEYSTORE -storepass $STOREPASS -keypass $KEYPASS

}

function substituteVars()
{
file=templates/$1
target=$2
sed -e "s,\$SERVER,$SERVER,g" \
-e "s,\$DOMAIN,$DOMAIN,g" \
-e "s,\$ADMIN_PASSWORD,$ADMIN_PASSWORD,g" \
-e "s,\$ADMIN_SALT,$ADMIN_SALT,g" \
-e "s,\$ADMIN_HASH,$ADMIN_HASH,g" \
-e "s,\$ADMIN_PREFIX,$ADMIN_PREFIX,g" \
-e "s,\$ADMIN_USER,$ADMIN_USER,g" \
-e "s,\$ADMIN_EMAIL,$ADMIN_EMAIL,g" \
-e "s,\$API_USER,$API_USER,g" \
-e "s,\$API_SECRET,$API_SECRET,g" \
-e "s,\$LABELS_SECRET,$LABELS_SECRET,g" \
-e "s,\$FORMS_SECRET,$FORMS_SECRET,g" \
-e "s,\$APACHE_LOGVERZ,$APACHE_LOGVERZ,g" \
-e "s,\$ARCHIVE_HOME,$ARCHIVE_HOME,g" \
-e "s,\$BACKEND,$BACKEND,g" \
-e "s,\$CRONJOBS_DIR,$CRONJOBS_DIR,g" \
-e "s,\$DATACITE_PASSWORD,$DATACITE_PASSWORD,g" \
-e "s,\$DATACITE_USER,$DATACITE_USER,g" \
-e "s,\$DATACITE_URL,$DATACITE_URL,g" \
-e "s,\$DATETIME,$DATETIME,g" \
-e "s,\$DOIPREFIX,$DOIPREFIX,g" \
-e "s,\$DOIRESOLVER,$DOIRESOLVER,g" \
-e "s,\$ELASTICSEARCH,$ELASTICSEARCH,g" \
-e "s,\$ELASTICSEARCH_CONF,$ELASTICSEARCH_CONF,g" \
-e "s,\$ELASTIC_PORT,$ELASTIC_PORT,g" \
-e "s,\$EMAIL,$EMAIL,g" \
-e "s,\$EMAIL_RECIPIENT_ADMIN_USERS,$EMAIL_RECIPIENT_ADMIN_USERS,g" \
-e "s,\$EMAIL_RECIPIENT_PROJECT_ADMIN,$EMAIL_RECIPIENT_PROJECT_ADMIN,g" \
-e "s,\$FEDORA_USER,$FEDORA_USER,g" \
-e "s,\$FEDORA_PASSWORD,$FEDORA_PASSWORD,g" \
-e "s,\$FRONTEND,$FRONTEND,g" \
-e "s,\$HERITRIX_DATA,$HERITRIX_DATA,g" \
-e "s,\$HERITRIX_DIR,$HERITRIX_DIR,g" \
-e "s,\$HERITRIX_URL,$HERITRIX_URL,g" \
-e "s,\$HERITRIX_PASSWORD,$HERITRIX_PASSWORD,g" \
-e "s,\$INDEXNAME,$INDEXNAME,g" \
-e "s,\$IP,$IP,g" \
-e "s,\$KEYSTORE,$KEYSTORE,g" \
-e "s,\$STOREPASS,$STOREPASS,g" \
-e "s,\$KEYPASS,$KEYPASS,g" \
-e "s,\$LABELS_PASSWORD,$LABELS_PASSWORD,g" \
-e "s,\$LINUX_GROUP,$LINUX_GROUP,g" \
-e "s,\$LINUX_USER,$LINUX_USER,g" \
-e "s,\$MYSQL_PASSWORD,$MYSQL_PASSWORD,g" \
-e "s,\$MYSQL_LABELS_PASSWORD,$MYSQL_LABELS_PASSWORD,g" \
-e "s,\$MYSQL_OAI_PASSWORD,$MYSQL_OAI_PASSWORD,g" \
-e "s%\$NAMESPACE%$NAMESPACE%g" \
-e "s,\$PASSWORD,$PASSWORD,g" \
-e "s,\$PLAYPORT,$PLAYPORT,g" \
-e "s,\$PROJECT,$PROJECT,g" \
-e "s,\$REGAL_ADMIN,$REGAL_ADMIN,g" \
-e "s,\$REGAL_APP,$REGAL_APP,g" \
-e "s,\$REGAL_BACKUP,$REGAL_BACKUP,g" \
-e "s,\$REGAL_LOGS,$REGAL_LOGS,g" \
-e "s,\$REGAL_PASSWORD,$REGAL_PASSWORD,g" \
-e "s,\$REGAL_TMP,$REGAL_TMP,g" \
-e "s,\$SSL_PUBLIC_CERT_BACKEND,$SSL_PUBLIC_CERT_BACKEND,g" \
-e "s,\$SSL_PRIVATE_KEY_BACKEND,$SSL_PRIVATE_KEY_BACKEND,g" \
-e "s,\$SSL_PUBLIC_CERT_FRONTEND,$SSL_PUBLIC_CERT_FRONTEND,g" \
-e "s,\$SSL_PRIVATE_KEY_FRONTEND,$SSL_PRIVATE_KEY_FRONTEND,g" \
-e "s,\$SSL_CHAIN_FRONTEND,$SSL_CHAIN_FRONTEND,g" \
-e "s,\$STATS_LOG,$STATS_LOG,g" \
-e "s,\$TMPDIR,$TMPDIR,g" \
-e "s,\$TOMCAT_CONF,$TOMCAT_CONF,g" \
-e "s,\$TOMCAT_HOME,$TOMCAT_HOME,g" \
-e "s,\$TOMCAT_PORT,$TOMCAT_PORT,g" \
-e "s,\$URNBASE,$URNBASE,g" \
-e "s,\$URNSNID,$URNSNID,g" \
-e "s,\$VERSION,$VERSION,g" \
-e "s,\$WAYBACK_SERVER,$WAYBACK_SERVER,g" \
-e "s,\$WAYBACK_PORT,$WAYBACK_PORT,g" \
-e "s,\$WHITELIST,$WHITELIST,g" $file > $target
}

makeDirs
createConfig
