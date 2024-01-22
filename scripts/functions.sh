#! /bin/bash

source variables.conf

function pidlist()
{
server=$BACKEND
contentType=$1
fromSrc=$2
from=$3
until=$4

curl -u$ARCHIVE_USER:$ARCHIVE_PASSWORD -XGET "http://$server/resource?contentContentType=$contentType&src=$fromSrc&from=$from&until=$until" -H"accept:application/json" 2> /dev/null| sed s/"{\"list\":"/""/g | sed s/"\,"/"\n"/g | sed s/"\"\([^\"]*\)".*/"\1"/g | sed s/"^\["/""/g
echo
}

function index()
{
contentType=$1
user=$ARCHIVE_USER
password=$ARCHIVE_PASSWORD
server=$BACKEND
for i in `pidlist $contentType repo 0 10000`
do
curl -s -u${user}:${password} -XPOST "http://$server/utils/index/$i?contentType=$contentType";echo
done
}

function public_index()
{
contentType=$1
user=$ARCHIVE_USER
password=$ARCHIVE_PASSWORD
server=$BACKEND
for i in `pidlist $contentType repo 0 10000`
do
curl -s -u ${user}:${password} -XPOST "http://$server/utils/publicIndex/$i?contentType=$contentType";echo
done
}

function delete()
{
contentType=$1
user=$ARCHIVE_USER
password=$ARCHIVE_PASSWORD
server=$BACKEND
for i in `pidlist $contentType repo 0 10000`
do
curl -s -u ${user}:${password} -XDELETE "http://$server/resource/$i";echo
done
}


function lobidify()
{
contentType=$1
user=$ARCHIVE_USER
password=$ARCHIVE_PASSWORD
server=$BACKEND
for i in `pidlist $contentType repo 0 10000`
do
curl -s -u ${user}:${password} -XPOST "http://$server/utils/lobidify/$i";echo
done
}

function generateIdTable()
{
contentType=$1
host=$FRONTEND
api=$BACKEND

list=`pidlist $contentType es 0 30000`

echo "|| Aleph || URN || DOI || URI ||"
for i in $list
do

ntriple=`curl -s $api/resource/${i}.rdf -H"accept:text/plain"`;
aleph=`echo $ntriple | grep -o "http://purl.org/lobid/lv#hbzID[^\^]*"|sed s/"http.*>"/""/|sed s/"\""/""/g`
urn=`echo $ntriple | grep -o "http://purl.org/lobid/lv#urn[^\.]*"|sed s/"http.*>"/""/|sed s/"\""/""/g| sed s/"\^\^.*"/""/`
doi=`echo $ntriple | grep -o "dx\.doi\.org/[^\>]*"| head -n 1`

uri=http://$host/resource/${i}

echo "| $aleph | $urn | $doi | $uri |"

done

}

function listCatalogIds ()
{
contentType=$1
server=$BACKEND

pidlist=`pidlist $contentType repo 0 10000`
for i in $pidlist;do TT=`curl -s http://${server}/fedora/objects/$i/datastreams/DC/content|grep -o "HT[^<]*\|TT[^<]*"`; echo $i,$TT;done >tmp

sort tmp |uniq
rm tmp
}


function pid2urn()
{
contentType=$1

generateIdTable $contentType > idTable.txt
while read line
do 
#echo $line
urn=`echo $line|grep -o "urn[^\ ]*"`
pid=`echo $line|grep -o "\($NAMESPACE:[0-9][0-9][0-9][0-9][0-9][0-9][0-9]\)\ \|$"`

echo $pid , $urn
done < idTable.txt | sort 

}


function testUrn()
{

contentType=$1
host=$FRONTEND

pid2urn $contentType $host >pid2urn.sorted.txt
while read line
do
pid=`echo $line|grep -o -m1 "^[^,]*"`
urn=`echo $line|grep -o -m1 "urn:nbn:de:hbz:929.*$"`
cout=`curl -s -I http://nbn-resolving.org/$urn`
out=`echo $cout | grep -o "HTTP........"`
test=`echo $cout |grep -o "307\|200"`
if [ $? -eq 0 ]
then
echo "http://$host/resource/$pid , http://nbn-resolving.org/$urn , $out , Success"
else
echo "http://$host/resource/$pid , http://nbn-resolving.org/$urn , $out , ERROR"
fi
done <pid2urn.sorted.txt
}

function testOai()
{
contentType=$1
host=$FRONTEND
api=$BACKEND

pid2urn $contentType >pid2urn.sorted.txt
while read line
do
pid=`echo $line|grep -o -m1 "^[^,]*"`
cout=`curl -s -i "http://$BACKEND/dnb-urn/?verb=GetRecord&metadataPrefix=oai_dc&identifier=http://$BACKEND/resource/$pid"`
out=`echo $cout | grep -o "code=.............."`
test=`echo $cout |grep -o "dc:identifier"`
if [ $? -eq 0 ]
then
echo "http://$host/resource/$pid , http://api.$host/dnb-urn/?verb=GetRecord&metadataPrefix=oai_dc&identifier=http://api.$host/resource/$pid , $out , Success"
else
echo "http://$host/resource/$pid , http://api.$host/dnb-urn/?verb=GetRecord&metadataPrefix=oai_dc&identifier=http://api.$host/resource/$pid , $out , ERROR"
fi
done <pid2urn.sorted.txt
}

function listParts(){
pid=$1
curl -s http://localhost:9000/resource/$pid/parts | sed s/","/" "/g | sed s/"[^\[]*\["/""/g | sed s/"\]\}"/""/|sed s/"\""/""/g
}

function listAllParts(){
list=`listParts $1`
for i in $list
do
listAllParts $i
echo $i
done
echo $1
}

function delete(){
pid=$1
deleteMe=`listAllParts $pid`
for i in $deleteMe
do
curl -u$ARCHIVE_USER:$ARCHIVE_PASSWORD -XDELETE $BACKEND/resource/$i
done
}
