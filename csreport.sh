#!/bin/sh

QUIET=false
SHORT=false
FILELIST=-
while getopts "qsf:" opt; do
    case "${opt}" in
    q)
        QUIET=true
        ;;
    s)
        SHORT=true
        ;;
    f)
        FILELIST="${OPTARG}"
        ;;
    esac
done

files=$(cat "${FILELIST}")
filecount=$(echo "${files}" | wc -l)

errtot=0
wrntot=0
filcnt=0
proccnt=0
linecount=0
while read file; do
    proccnt=$(expr "${proccnt}" + 1)
    "${QUIET}" || echo "processing ${proccnt} of ${filecount} : ${file}" >&2

    lncnt=$(wc -l < "${file}")
    linecount=$(expr "${linecount}" + "${lncnt}")

    if ! phpcs=$(phpcs --standard=DWS --report=summary "${file}"); then
        counts=$(echo "${phpcs}" | sed '/A TOTAL OF/!d; s/A TOTAL OF \([0-9]\+\) ERROR(S) AND \([0-9]\+\) WARNING(S) .*/\1 \2/')
        read errcnt wrncnt <<< "${counts}"

        filcnt=$(expr "${filcnt}" + 1)
        errtot=$(expr "${errcnt}" + "${errtot}")
        wrntot=$(expr "${wrncnt}" + "${wrntot}")
    fi
done <<< "${files}"

if "${SHORT}"; then
  echo "${filecount} ${linecount} ${filcnt} ${errtot} ${wrntot}"
else
  echo "Total Files: ${filecount}"
  echo "Total Lines: ${linecount}"
  echo "Files with problems: ${filcnt}"
  echo "Errors: ${errtot}"
  echo "Warnings: ${wrntot}"
fi
