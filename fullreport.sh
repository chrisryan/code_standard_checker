#!/bin/sh

workingDir=`dirname $0`

TMPFILE=`mktemp`
find /www/files -type f | grep -v "/www/files/research/" | grep -v "/sitelogs/" | grep -v "/coldfusion/" > $TMPFILE

$workingDir/csreport.sh -f $TMPFILE

rm $TMPFILE
