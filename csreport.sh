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

TMPFILE2=$(mktemp)
echo "${files}" | tr -s '\n' '\000' > "${TMPFILE2}"
linecount=$(wc -l --files0-from="${TMPFILE2}" | tail -n 1 | awk '{print $1}')
[ -z "${linecount}" ] && linecount="0"

errtot=0
wrntot=0
filcnt=0
proccnt=0
while read file; do
    proccnt=$(expr "${proccnt}" + 1)
    "${QUIET}" || echo "processing ${proccnt} of ${filecount} : ${file}" >&2

    result=$(phpcs --standard=DWS --report=summary ${file} | grep "^A TOTAL")
    if [ -n "${result}" ]; then
        errcnt=$(echo "${result}" | awk '{print $4}')
        wrncnt=$(echo "${result}" | awk '{print $7}')

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

rm "${TMPFILE2}"
