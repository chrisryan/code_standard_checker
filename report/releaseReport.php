<?php

$mongo = new MongoClient();
$db = $mongo->selectDB('tolMergeStats');
$collection = new MongoCollection($db, 'merges');

$mergeReportCommand = dirname(dirname(__FILE__)) . '/bin/mergeReport';

exec('git log --merges --format="%h|||%p|||%s" --since=03/17/14', $logData);

foreach ($logData as $logLine) {
    $reportData = array();
    $arLog = explode('|||', $logLine);
    $commitHash = $arLog[0];
    $arParents = explode(' ', $arLog[1]);
    $commitMessage = $arLog[2];
    if ($collection->findOne(array('Hash' => $commitHash)) == null) {
        exec($mergeReportCommand . ' -sqc ' . $commitHash, $reportData);
        $reportData = isset($reportData[0]) ? explode(' ', $reportData[0]) : [];
        if (count($reportData) == 5) {
            $collection->insert(
                array(
                    'Hash' => $commitHash,
                    'Message' => $commitMessage,
                    'Parents' => $arParents,
                    'Files Added' => $reportData[0],
                    'Lines Added' => $reportData[1],
                    'Problem Files Added' => $reportData[2],
                    'Errors Added' => $reportData[3],
                    'Warnings Added' => $reportData[4],
                )
            );
        }
    }
}
