#!/bin/bash

PULL=
REMOTE=
shortFlag=''
quietFlag=''
githubToken=''
while getopts "sqr:p:g:" opt; do
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
    g)
        githubToken="${OPTARG}"
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

result=$(${workingDir}/mergeReport.sh ${quietFlag} ${shortFlag} -c "${localRef}" -b "${REMOTE}/master")
echo "${result}"

githubComment="This comment was generated automatically by the [coding standard checker](https://github.com/chrisryan/code_standard_checker).\\n\\n${result//
/\\n}"

if [ -n "${githubToken}" ]; then
    githubRepo=$(git config --get "remote.${REMOTE}.url" | sed 's#.*[:/]\([^/]\+/[^/.]\+\)\.git.*#\1#')
    curl -H "Authorization: token ${githubToken}" -d "{\"body\": \"${githubComment}\"}" "https://api.github.com/repos/${githubRepo}/issues/${PULL}/comments"
fi
