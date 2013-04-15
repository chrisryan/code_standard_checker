#!/bin/sh

TMPFILE=`mktemp`
find /www/files -type f | grep -v "/www/files/research/" | grep -v "\.git" | grep -v "\.zip" | grep -v "\.jar" | grep -v "\.cab" | grep -v "/sitelogs/" | grep -v "/coldfusion/" | grep -v "\.gif" | grep -v "\.jpg" | grep -v "\.png" | grep -v "\.jpeg" > $TMPFILE
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
