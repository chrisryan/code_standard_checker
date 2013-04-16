#!/bin/sh

workingDir=`dirname $0`

TMPFILE=`mktemp`
find /www/files -type f | grep -v "/www/files/research/" | grep -v "\.git" | grep -v "\.zip" | grep -v "\.jar" | grep -v "\.cab" | grep -v "/sitelogs/" | grep -v "/coldfusion/" | grep -v "\.gif" | grep -v "\.jpg" | grep -v "\.png" | grep -v "\.jpeg" > $TMPFILE

$workingDir/csreport.sh -f $TMPFILE

rm $TMPFILE
