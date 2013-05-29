<?php
$appPath = __DIR__;
$prCheckPath = "${appPath}/bin/prCheck";
$githubToken = getenv('GITHUB_API_TOKEN');

$mongoUrl = parse_url(getenv('MONGOHQ_URL'));
$dbName = str_replace('/', '', $mongoUrl['path']);

$m = new Mongo(getenv('MONGOHQ_URL'));
$db = $m->$dbName;
$pulls = $db->pulls;

foreach ($pulls->find() as $pull) {
    echo "Handling PR #{$pull['number']} for {$pull['repository']}\n";
    $pulls->remove($pull);

    $command = "{$prCheckPath} -r origin -p {$pull['number']} -g {$githubToken} -R {$pull['repository']} {$appPath}/data/${pull['repository']}";
    echo "Executing {$command}\n";
    $exitStatus = null;
    passthru($command, $exitStatus);
    if ($exitStatus !== 0) {
        $pulls->insert($pull);
    }
}
