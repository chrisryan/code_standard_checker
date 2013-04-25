#!/bin/sh

workingDir=`dirname $0`

$workingDir/getFiles.sh /www/files | $workingDir/csreport.sh -f -
