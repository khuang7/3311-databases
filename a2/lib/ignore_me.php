<?php 

function ign($db,$groupID){
    $regex = "TELE412[01]";
    $q = "select distinct sub.code from subjects sub where sub.code ~ %s;";
    $subs = dbOneTuple($db, mkSQL($q, $regex));
    print_r($subs);
    echo count($subs);
    return array('hello', $subs);
}
?>