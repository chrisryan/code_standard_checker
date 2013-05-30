<?php
$appPath = __DIR__;
$prCheckPath = "${appPath}/bin/prCheck";
$githubCommentPath = "${appPath}/bin/githubComment";
$githubToken = getenv('GITHUB_API_TOKEN');

$mongoUrl = parse_url(getenv('MONGOHQ_URL'));
$dbName = str_replace('/', '', $mongoUrl['path']);

$m = new Mongo(getenv('MONGOHQ_URL'));
$db = $m->$dbName;
$pulls = $db->pulls;
$pullResults = $db->pullResults;

foreach ($pulls->find() as $pull) {
    echo "Handling PR #{$pull['number']} for {$pull['repository']}\n";
    $pulls->remove($pull);

    $repositoryPath = "{$appPath}/data/${pull['repository']}";
    $command = "{$prCheckPath} -r origin -p {$pull['number']} -g {$githubToken} -R {$pull['repository']} -s {$repositoryPath}";
    echo "Executing {$command}\n";
    $exitStatus = null;
    $output = null;
    exec($command, $output, $exitStatus);
    $fields = explode(' ', implode(' ', $output));
    if ($exitStatus !== 0 || count($fields) !== 5) {
        echo "Unexpected number of fields in prCheck result.\n";
        $pulls->insert($pull);
        continue;
    }

    $pullQuery = array('repository' => $pull['repository'], 'number' => $pull['number']);
    $results = array();
    list($results['filesAdded'], $results['linesAdded'], $results['probFilesAdded'], $results['errorsAdded'], $results['warnAdded']) = $fields;
    $previousResults = $pullResults->findOne($pullQuery, array('_id' => false, 'number' => false, 'repository' => false));
    if ($previousResults == $results) {
        echo "Results were identical to last run.\n";
        continue;
    }

    $resultMessage = function($type, $i) {
        $addedOrDeleted = $i >= 0 ? 'Added' : 'Deleted';
        return "{$type} {$addedOrDeleted}: " . abs($i);
    };

    $message = implode(
        "\n",
        array(
            $resultMessage('Files', $results['filesAdded']),
            $resultMessage('Lines', $results['linesAdded']),
            $resultMessage('Problem Files', $results['probFilesAdded']),
            $resultMessage('PHPCS Errors', $results['errorsAdded']),
            $resultMessage('PHPCS Warnings', $results['warnAdded']),
        )
    );

    passthru("{$githubCommentPath} -R {$pull['repository']} -p {$pull['number']} -g {$githubToken} -m " . escapeshellarg($message));
    $pullResults->update($pullQuery, array('$set' => $results), array('upsert' => true));
}
