#!/bin/bash

PULL=
REMOTE=
SHORT=0
QUIET=0
while getopts "sqr:p:" opt; do
    case "$opt" in
    s)
        SHORT=1
        ;;
    q)
        QUIET=1
        ;;
    p)
        PULL=$OPTARG
        ;;
    r)
        REMOTE=$OPTARG
        ;;
    esac
done

if [ "$PULL" = '' ]
then
    echo Must specify a pull request number
    exit
fi

if [ "$REMOTE" = '' ]
then
    echo Must specify a remote
    exit
fi

if ! git fetch $REMOTE +refs/pull/$PULL/head:refs/remotes/$REMOTE/pr/$PULL
then
    echo Unknown error
    exit
fi

workingDir=$(dirname $0)

if [ "$(git status -s)" != "" ]
then
  echo Must have a clean working directory
  exit
fi

STARTINGCOMMIT=$(git rev-parse --abbrev-ref HEAD)

if [ "$STARTINGCOMMIT" = "HEAD" ]
then
  STARTINGCOMMIT=$(git log -1 --format=%H HEAD)
fi

TMPFILE=`mktemp`
git diff --name-only $REMOTE/master $REMOTE/pr/$PULL > $TMPFILE

if [ $QUIET = 0 ]
then
  git checkout $REMOTE/master

  AFTER=($($workingDir/csreport.sh -sf $TMPFILE))

  git checkout $REMOTE/pr/$PULL

  BEFORE=($($workingDir/csreport.sh -sf $TMPFILE))

  git checkout $STARTINGCOMMIT
else
  git checkout -q $REMOTE/master

  AFTER=($($workingDir/csreport.sh -qsf $TMPFILE))

  git checkout -q $REMOTE/pr/$PULL

  BEFORE=($($workingDir/csreport.sh -qsf $TMPFILE))

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

rm $TMPFILE
