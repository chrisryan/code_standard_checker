#!/bin/sh
workingDir=`dirname $0`

if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` codeDirectory" >&2
    exit 1;
fi

codeDir=$1

find $codeDir -type f \
    \! -name '*.zip' \
    \! -name '*.jar' \
    \! -name '*.cab' \
    \! -name '*.gif' \
    \! -name '*.png' \
    \! -name '*.jpg' \
    \! -name '*.jpeg' \
    \! -name '*.sql' \
    \! -name '*.qry' \
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
    \! -path '*/plupload/*'
