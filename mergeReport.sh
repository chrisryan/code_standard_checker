#!/bin/bash

SHORT=0
QUIET=0
showOnlyTracking=false
mergeRef='HEAD'
while getopts "qstc:" opt; do
    case "$opt" in
    s)
        SHORT=1
        ;;
    q)
        QUIET=1
        ;;
    t)
        showOnlyTracking=true
        ;;
    c)
        mergeRef="${OPTARG}"
        ;;
    esac
done

workingDir=$(dirname $0)

if ! git diff-index --quiet HEAD; then
  echo 'Must have a clean working directory' >&2
  exit 1
fi

MERGEHASH=$(git rev-parse "${mergeRef}")
STARTINGCOMMIT=$(git rev-parse --abbrev-ref HEAD)
if [ "${STARTINGCOMMIT}" = 'HEAD' ]; then
    STARTINGCOMMIT=$(git rev-parse HEAD)
fi

gitDiffFiles=$(git diff-tree --no-commit-id --name-only -m -r "${MERGEHASH}" | sort)
processFiles="${gitDiffFiles}"

if "${showOnlyTracking}"; then
    trackingFiles=$(${workingDir}/getFiles.sh | sed 's#^./##' | sort)
    changedAndTrackedFiles=$(comm -12 <(echo "${gitDiffFiles}") <(echo "${trackingFiles}"))
    processFiles="${changedAndTrackedFiles}"
fi

if [ $QUIET = 0 ]
then
  git checkout $MERGEHASH
  AFTER=($(echo "${processFiles}" | ${workingDir}/csreport.sh -sf -))

  git checkout $MERGEHASH~
  BEFORE=($(echo "${processFiles}" | ${workingDir}/csreport.sh -sf -))

  git checkout $STARTINGCOMMIT
else
  git checkout -q $MERGEHASH
  AFTER=($(echo "${processFiles}" | ${workingDir}/csreport.sh -qsf -))

  git checkout -q $MERGEHASH~
  BEFORE=($(echo "${processFiles}" | ${workingDir}/csreport.sh -qsf -))

  git checkout -q $STARTINGCOMMIT
fi

FILESADDED=$(expr ${AFTER[0]} - ${BEFORE[0]})
LINESADDED=$(expr ${AFTER[1]} - ${BEFORE[1]})
PROBFILESADDED=$(expr ${AFTER[2]} - ${BEFORE[2]})
ERRORSADDED=$(expr ${AFTER[3]} - ${BEFORE[3]})
WARNADDED=$(expr ${AFTER[4]} - ${BEFORE[4]})

if [ $SHORT = 0 ]
then
  if [ $FILESADDED -lt 0 ]
  then
    echo "Files Deleted: `expr $FILESADDED \* -1`"
  else
    echo "Files Added: $FILESADDED"
  fi

  if [ $LINESADDED -lt 0 ]
  then
    echo "Lines Deleted: `expr $LINESADDED \* -1`"
  else
    echo "Lines Added: $LINESADDED"
  fi

  if [ $PROBFILESADDED -lt 0 ]
  then
    echo "Files Cleaned: `expr $PROBFILESADDED \* -1`"
  else
    echo "New Files with Problems: $PROBFILESADDED"
  fi

  if [ $ERRORSADDED -lt 0 ]
  then
    echo "Errors Deleted: `expr $ERRORSADDED \* -1`"
  else
    echo "Errors Added: $ERRORSADDED"
  fi

  if [ $WARNADDED -lt 0 ]
  then
    echo "Warnings Deleted: `expr $WARNADDED \* -1`"
  else
    echo "Warnings Added: $WARNADDED"
  fi
else
  echo "$FILESADDED $LINESADDED $PROBFILESADDED $ERRORSADDED $WARNADDED"
fi
