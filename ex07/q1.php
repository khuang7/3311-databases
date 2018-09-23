<?
$x = 3.0;

$x = (int)$x / 2;

$x = 1 + (int)$x * 2;

$x = "$x times $x";

$x = $x * 5 / 3;

$x = 'Why $x?';

$x = $x + 3.14159;
print_r($x);
echo gettype($x);
?>