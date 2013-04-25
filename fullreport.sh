#!/bin/sh
workingDir=`dirname $0`
codeDir=${1-/www/files}

$workingDir/getFiles.sh $codeDir | $workingDir/csreport.sh -f -
