<?php


// 451000 272000
function floorToFirst($int) {
    if (0 === $int) return 0;

    $nearest = pow(10, floor(log($int, 10)));
    return floor($int / $nearest) * $nearest;
}

function g($x) {
	return 7*(1299-$x)+2;
}

function h($x) {
	$x=$x/100;
	$x=floor($x);
	return $x;
}

$myFile = "data/speed45.asc";
$lines = file($myFile);//file in to an array
for ($a = 0; $a < 1300; $a++) {
  for ($b = 0; $b < 700; $b++) {
    $string = $lines[g($a)+h($b)-1]; //line 2

    $string=explode(";", $string);
    echo 1*($string[1-floorToFirst($b)+$b]) . ' ';
  }
  echo "\n";
}

?>
