#!/bin/sh

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



filecount=`wc -l $TMPFILE | awk '{print $1}'`
TMPFILE2=`mktemp`
tr -s '\n' '\000' < $TMPFILE > $TMPFILE2
linecount=`wc -l --files0-from=$TMPFILE2 | tail -n 1 | awk '{print $1}'`
errtot=0
wrntot=0
filcnt=0
proccnt=0;
for file in `grep -v "\.min\.js" $TMPFILE`; do
    proccnt=$(($proccnt + 1))
    echo "processing $proccnt of $filecount"
    result=`phpcs --standard=DWS --report=summary $file | grep "^A TOTAL"`
    if [ ! -z "$result" ]; then
        errcnt=`echo $result | awk '{print $4}'`
        wrncnt=`echo $result | awk '{print $7}'`
        filcnt=$(($filcnt + 1))
        errtot=`expr $errcnt + $errtot`
        wrntot=`expr $wrncnt + $wrntot`
    fi
done
echo "Total Files: $filecount"
echo "Total Lines: $linecount"
echo "Files with problems: $filcnt"
echo "Errors: $errtot"
echo "Warnings: $wrntot"

rm $TMPFILE
rm $TMPFILE2
