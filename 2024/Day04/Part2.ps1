Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$Dimension = $Data.Length
$extends = @('MS','SM')
for ($i = 0; $i -lt $Dimension*$Dimension; $i++) {
  $DivRem = [System.Math]::DivRem($i,$Dimension)
  $x = $DivRem.Item2
  $y = $DivRem.Item1
  if ($x -eq 0 -or $x -eq $Dimension-1 -or $y -eq 0 -or $y -eq $Dimension-1) {continue}
  if ($Data[$y][$x] -ne 'A') {continue}
  # If we are at an A that is not on the border of the grid
  $LeftDown = $Data[$y-1][$x-1] + $Data[$y+1][$x+1]
  $LeftUp = $Data[$y+1][$x-1] + $Data[$y-1][$x+1]
  if ($LeftDown -in $extends -and $LeftUp -in $extends) { $Result++ }
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 1992 (9 for testdata)