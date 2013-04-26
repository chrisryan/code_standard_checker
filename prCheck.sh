#!/bin/bash

PULL=
REMOTE=
shortFlag=''
quietFlag=''
while getopts "sqr:p:" opt; do
    case "$opt" in
    s)
        shortFlag='-s'
        ;;
    q)
        quietFlag='-q'
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

workingDir=$(realpath $(dirname "${0}"))

shift $(expr "${OPTIND}" - 1)
codeDir="${1:-.}"
cd "${codeDir}" || exit 1

localRef="${REMOTE}/pr/${PULL}"
if ! git fetch "${REMOTE}" "+refs/pull/${PULL}/head:refs/remotes/${localRef}"; then
    echo 'Unknown error' >&2
    exit 1
fi

${workingDir}/mergeReport.sh ${quietFlag} ${shortFlag} -c "${localRef}" -b "${REMOTE}/master"
