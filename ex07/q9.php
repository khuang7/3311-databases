<?
require("db.php");
$db = dbConnect("dbname = beer2");
$query = <<<xxSQLxx
select b.name, avg(s.price)
from sells s, beers b
where s.beer = b.id
group by b.name;

xxSQLxx;
$results = dbQuery($db, mkSQL($query));
while($tuple = dbNext($results)) {
	printf("%-20.20s %6.2f\n", $tuple[0], $tuple[1]);
}
?>