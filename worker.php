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

foreach ($pulls->find() as $pull) {
    echo "Handling PR #{$pull['number']} for {$pull['repository']}\n";
    $pulls->remove($pull);

    $command = "{$prCheckPath} -r origin -p {$pull['number']} -g {$githubToken} -R {$pull['repository']} {$appPath}/data/${pull['repository']}";
    echo "Executing {$command}\n";
    $exitStatus = null;
    $output = null;
    exec($command, $output, $exitStatus);
    $output = implode("\n", $output) . "\n";
    echo $output;

    if ($exitStatus === 0) {
        passthru("{$githubCommentPath} -R {$pull['repository']} -p {$pull['number']} -g {$githubToken} -m " . escapeshellarg($output));
    } else {
        $pulls->insert($pull);
    }
}
