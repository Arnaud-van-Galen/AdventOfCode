function GrootsteGemeneDeler {param($a, $b)
  while ($b -ne 0) {
    $temp = $b
    $b = $a % $b
    $a = $temp
  }
  return $a
}

function KleinsteGemeneVeelvoud {param($a, $b)
  if ($a -eq 0 -or $b -eq 0) {return 0} else {return [Math]::Abs($a * $b) / (GrootsteGemeneDeler $a $b)}
}

$Steps = @(20221, 11911, 21883, 16343, 18559, 16897) # 16563603485021
# $Steps = @(11911, 16343) # 702749
$KGV = $Steps[0]
foreach ($number in $Steps[1..($Steps.Length - 1)]) {$KGV = KleinsteGemeneVeelvoud $KGV $number}
'{0:0}' -f $KGV