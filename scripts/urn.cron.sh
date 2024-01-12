#! /bin/bash

source functions.sh

date=`date --date="7 days ago" "+%Y-%m-%d"`

curl -s -XPOST -u$ADMIN_USER:$PASSWORD "$BACKEND/utils/addUrnToAll?namespace=$NAMESPACE&snid=hbz:929:02&dateBefore=$date"
