<?php
$stderr = fopen('php://stderr', 'w');

$request = file_get_contents('php://input');
if ($request === false) {
    fwrite($stderr, "Request was false\n");
    return;
}

$request = json_decode($request, true);
if ($request === null) {
    fwrite($stderr, "Request was null\n");
    return;
}

if (!array_key_exists('number', $request)) {
    fwrite($stderr, "Request did not have number\n" . var_export($request, true));
    return;
}

if ($request['pull_request']['state'] !== 'open') {
    fwrite($stderr, "Request was not open but was in state {$request['pull_request']['state']}\n");
    return;
}

fwrite($stderr, "Processing request\n");
$repository = $request['repository']['full_name'];
$pullNumber = $request['number'];
$mergeHash = $request['pull_request']['merge_commit_sha'];

$mongoUrl = parse_url(getenv('MONGOHQ_URL'));
$dbName = str_replace('/', '', $mongoUrl['path']);

$m = new Mongo(getenv('MONGOHQ_URL'));
$db = $m->$dbName;
$processedCommits = $db->processedCommits;

if ($processedCommits->findOne(array('mergeHash' => $mergeHash)) === null) {
    $processedCommits->insert(array('mergeHash' => $mergeHash));

    $pulls = $db->pulls;
    $pulls->insert(array('repository' => $repository, 'number' => $pullNumber));
}
