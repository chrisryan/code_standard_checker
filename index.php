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

fwrite($stderr, "Processing request\n");
$repository = $request['repository']['full_name'];
$pullNumber = $request['number'];

$mongoUrl = parse_url(getenv('MONGOHQ_URL'));
$dbName = str_replace('/', '', $mongoUrl['path']);

$m = new Mongo(getenv('MONGOHQ_URL'));
$db = $m->$dbName;
$pulls = $db->pulls;

$pulls->insert(array('repository' => $repository, 'number' => $pullNumber));
