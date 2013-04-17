#!/bin/sh

workingDir=`dirname $0`

TMPFILE=`mktemp`

find /www/files -type f \
    \! -name '*.zip' \
    \! -name '*.jar' \
    \! -name '*.cab' \
    \! -name '*.gif' \
    \! -name '*.png' \
    \! -name '*.jpg' \
    \! -name '*.jpeg' \
    \! -path '*/.git/*' \
    \! -path '*/www/files/research/*' \
    \! -path '*/coldfusion/*' \
    \! -path '*/Zend/*' \
    \! -path '*/pear/*' \
    \! -path '*/sitelogs/*' \
    \! -path '*/Google/*' \
    \! -path '*/abraham-twitteroauth-76446fa/*' \
    \! -path '*/library/CAS/*' \
    \! -path '*/PEAR/*' \
    \! -path '*/Apache/*' \
    \! -path '*/CodeCoverage/Report/*' \
    \! -path '*/about/newsletter/*' \
    \! -path '*/feeds/include/xsd/STAR/*' \
    \! -path '*/phpseclib/*' \
    > $TMPFILE

$workingDir/csreport.sh -f $TMPFILE

rm $TMPFILE
