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
    \! -name '*.ico' \
    \! -name '*.sql' \
    \! -name '*.qry' \
    \! -name '*.js' \
    \! -name '*.css' \
    \! -name '*.json' \
    \! -name '*.sh' \
    \! -name '*.txt' \
    \! -name '*.gitignore' \
    \! -name '*.xls' \
    \! -name '*.ini' \
    \! -name '*.lock' \
    \! -name '*.xml' \
    \! -name '*.xslt' \
    \! -name '*.xsd' \
    \! -name '*.wsdl' \
    \! -name '*.wddx' \
    \! -name '*.svgz' \
    \! -name '*woff' \
    \! -name '*svg' \
    \! -name '*eot' \
    \! -name '*.pdf' \
    \! -name '*.conf' \
    \! -name '*.basemod' \
    \! -name '*.base' \
    \! -name '*.md' \
    \! -name '*.markdown' \
    \! -name '*.git' \
    \! -path '*/.git/*' \
    \! -path '*/vendor/*' \
    \! -path '*/www/files/research/*' \
    \! -path '*/coldfusion/*' \
    \! -path '*/PhoneFactor/*' \
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
    \! -path '*/newsletter/*.html' \
    \! -path '*/feeds/include/xsd/STAR/*' \
    \! -path '*/phpseclib/*' \
    \! -path '*/plupload/*'
