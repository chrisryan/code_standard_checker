#!/bin/bash

short=false
quietFlag=''
showOnlyTracking=false
mergeRef='HEAD'
while getopts "qstc:" opt; do
    case "${opt}" in
        s)
            short=true
            ;;
        q)
            quietFlag='-q'
            ;;
        t)
            showOnlyTracking=true
            ;;
        c)
            mergeRef="${OPTARG}"
            ;;
    esac
done

workingDir=$(realpath $(dirname "${0}"))

shift $(expr "${OPTIND}" - 1)
codeDir="${1:-.}"
cd "${codeDir}" || exit 1

if ! git diff-index --quiet HEAD; then
    echo 'Must have a clean working directory' >&2
    exit 1
fi

mergeHash=$(git rev-parse "${mergeRef}")
startingCommit=$(git rev-parse --abbrev-ref HEAD)
if [ "${startingCommit}" = 'HEAD' ]; then
    startingCommit=$(git rev-parse HEAD)
fi

gitDiffFiles=$(git diff-tree --no-commit-id --name-only -m -r "${mergeHash}" | sort)
processFiles="${gitDiffFiles}"

if "${showOnlyTracking}"; then
    trackingFiles=$(${workingDir}/getFiles.sh | sed 's#^./##' | sort)
    changedAndTrackedFiles=$(comm -12 <(echo "${gitDiffFiles}") <(echo "${trackingFiles}"))
    processFiles="${changedAndTrackedFiles}"
fi

git checkout ${quietFlag} "${mergeHash}" >&2
afterStats=($(echo "${processFiles}" | ${workingDir}/csreport.sh ${quietFlag} -s))

git checkout ${quietFlag} "${mergeHash}~" >&2
beforeStats=($(echo "${processFiles}" | ${workingDir}/csreport.sh ${quietFlag} -s))

git checkout ${quietFlag} "${startingCommit}" >&2

filesAdded=$(expr "${afterStats[0]}" - "${beforeStats[0]}")
linesAdded=$(expr "${afterStats[1]}" - "${beforeStats[1]}")
probFilesAdded=$(expr "${afterStats[2]}" - "${beforeStats[2]}")
errorsAdded=$(expr "${afterStats[3]}" - "${beforeStats[3]}")
warnAdded=$(expr "${afterStats[4]}" - "${beforeStats[4]}")

if "${short}"; then
    echo "${filesAdded} ${linesAdded} ${probFilesAdded} ${errorsAdded} ${warnAdded}"
else
    if [ "${filesAdded}" -lt 0 ]; then
        echo "Files Deleted: $(expr "${filesAdded}" \* -1)"
    else
        echo "Files Added: ${filesAdded}"
    fi

    if [ "${linesAdded}" -lt 0 ]; then
        echo "Lines Deleted: $(expr "${linesAdded}" \* -1)"
    else
        echo "Lines Added: ${linesAdded}"
    fi

    if [ "${probFilesAdded}" -lt 0 ]; then
        echo "Files Cleaned: $(expr "${probFilesAdded}" \* -1)"
    else
        echo "New Files with Problems: ${probFilesAdded}"
    fi

    if [ "${errorsAdded}" -lt 0 ]; then
        echo "Errors Deleted: $(expr "${errorsAdded}" \* -1)"
    else
        echo "Errors Added: ${errorsAdded}"
    fi

    if [ "${warnAdded}" -lt 0 ]; then
        echo "Warnings Deleted: $(expr "${warnAdded}" \* -1)"
    else
        echo "Warnings Added: ${warnAdded}"
    fi
fi
