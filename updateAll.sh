#! /bin/bash

cd /opt/regal/cronjobs

source variables.conf

INDEXNAME=edoweb

curl -s -XGET localhost:9200/$INDEXNAME/journal,monograph,webpage/_search -d'{"query":{"match_all":{}},"fields":["/@id"],"size":"50000"}'|egrep -o "$INDEXNAME:[^\"]*">$ARCHIVE_HOME/logs/titleObjects.txt

num=`cat $ARCHIVE_HOME/logs/pids.txt|wc -l`
yesterday=`date -d "yesterday 00:00" '+%Y%m%d'`
log=$ARCHIVE_HOME/logs/lobidify-`date +"%Y%m%d"`.log

echo "Update $num resources if changed after $yesterday. Details under $ARCHIVE_HOME/logs/pids.txt." 

echo "lobidify & enrich"
cat $ARCHIVE_HOME/logs/titleObjects.txt | parallel --jobs 5 ./updatePid.sh {} https://api.edoweb-test.hbz-nrw.de $yesterday  >$log 2>&1
cp $log /tmp/updateMetadata
echo "Summary" >> $log
echo "Updated
grep  "Enrichment.*succeeded!" /tmp/updateMetadata | grep -v "Not updated"|grep -o "edoweb:[^\ ]*" >> $log
cd -
