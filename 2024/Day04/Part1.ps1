Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$Dimension = $Data.Length
$Search = 'XMAS'
$SearchLength = $Search.Length
for ($i = 0; $i -lt $Dimension*$Dimension; $i++) {
  $DivRem = [System.Math]::DivRem($i,$Dimension)
  $x = $DivRem.Item2
  $y = $DivRem.Item1

  if ($Data[$y][$x] -ne $Search[0]) {continue}
  # If we are at an X
  $CanFitRight = $x -le $Dimension-$SearchLength
  $CanFitLeft = $x -ge $SearchLength-1
  $CanFitDown = $y -le $Dimension-$SearchLength
  $CanFitUp = $y -ge $SearchLength-1
  if ($CanFitRight) {
    $Chars = $Data[$y][$x]
    for ($j = 1; $j -lt $SearchLength; $j++) { $Chars += $Data[$y][$x+$j] }
    if ($Chars -eq $Search) { $Result++ }
  }
  if ($CanFitLeft) {
    $Chars = $Data[$y][$x]
    for ($j = 1; $j -lt $SearchLength; $j++) { $Chars += $Data[$y][$x-$j] }
    if ($Chars -eq $Search) { $Result++ }
  }
  if ($CanFitDown) {
    $Chars = $Data[$y][$x]
    for ($j = 1; $j -lt $SearchLength; $j++) { $Chars += $Data[$y+$j][$x] }
    if ($Chars -eq $Search) { $Result++ }
  }
  if ($CanFitUp) {
    $Chars = $Data[$y][$x]
    for ($j = 1; $j -lt $SearchLength; $j++) { $Chars += $Data[$y-$j][$x] }
    if ($Chars -eq $Search) {$Result++}
  }
  if ($CanFitRight -and $CanFitDown) {
    $Chars = $Data[$y][$x]
    for ($j = 1; $j -lt $SearchLength; $j++) { $Chars += $Data[$y+$j][$x+$j] }
    if ($Chars -eq $Search) {$Result++}
  }
  if ($CanFitLeft -and $CanFitDown) {
    $Chars = $Data[$y][$x]
    for ($j = 1; $j -lt $SearchLength; $j++) { $Chars += $Data[$y+$j][$x-$j] }
    if ($Chars -eq $Search) {$Result++}
  }
  if ($CanFitRight -and $CanFitUp) {
    $Chars = $Data[$y][$x]
    for ($j = 1; $j -lt $SearchLength; $j++) { $Chars += $Data[$y-$j][$x+$j] }
    if ($Chars -eq $Search) {$Result++}
  }
  if ($CanFitLeft -and $CanFitUp) {
    $Chars = $Data[$y][$x]
    for ($j = 1; $j -lt $SearchLength; $j++) { $Chars += $Data[$y-$j][$x-$j] }
    if ($Chars -eq $Search) {$Result++}
  }
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 2571 (18 for testdata)