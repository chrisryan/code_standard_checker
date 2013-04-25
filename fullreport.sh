#!/bin/sh

workingDir=`dirname $0`

TMPFILE=`mktemp`

$workingDir/getFiles.sh /www/files > $TMPFILE
$workingDir/csreport.sh -f $TMPFILE

rm $TMPFILE
