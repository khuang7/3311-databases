<?
require("db.php");
$db = dbConnect("dbname = beer2");
$query = "select id, name, addr from bars";
$results = dbQuery($db, mkSQL($query));
while($tuple = dbNext($results)) {
	echo "$tuple[0], $tuple[1], $tuple[2]\n";
}
?>