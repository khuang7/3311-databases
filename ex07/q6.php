<?
$dbconn = pg_connect("dbname=beer2");
if(!$dbconn) {
	echo "it aint work mate\n";
}

$query = "select id, name, addr from bars";
$result = pg_query($dbconn, $query);
if(!$result) {
	echo "it also aint work bro";
}

while ($row = pg_fetch_row($result)) {
	echo "$row[0], $row[1], $row[2]\n";
}
?>