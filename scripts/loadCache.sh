#! /bin/bash

source variables.conf

INDEXNAME=$INDEXNAME
PLAYPORT=9000

curl -s -XGET localhost:9200/$INDEXNAME/issue,journal,monograph,volume,file/_search -d'{"query":{"match_all":{}},"fields":["/@id"],"size":"50000"}'|grep -o "$NAMESPACE:[^\"]*" >$ARCHIVE_HOME/logs/pids.txt


curl -s -XGET localhost:9200/$INDEXNAME/journal/_search -d '{"query":{"match_all":{}},"fields":["/@id"],"size":"50000"}'|grep -o "$NAMESPACE:[^\"]*" >$ARCHIVE_HOME/logs/journalPids.txt


echo "Try to load resources to cache:"
cat $ARCHIVE_HOME/logs/journalPids.txt

cat $ARCHIVE_HOME/logs/journalPids.txt | parallel --jobs 5 curl -s -u$ADMIN_USER:$PASSWORD -XGET http://localhost:$PLAYPORT/resource/{}/all/lastModified -H"accept: application/json"  >$ARCHIVE_HOME/logs/initCache-`date +"%Y%m%d"`.log 2>&1

