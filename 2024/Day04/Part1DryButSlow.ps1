Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

function MatchesSearchInGrid { param( [int] $startY, [int] $startX, [ValidateSet(-1, 0, 1)][int] $ScanDown, [ValidateSet(-1, 0, 1)][int] $ScanRight )
  for ($i = 0; $i -lt $SearchLength; $i++) {
    $y = $startY+($i*$ScanDown)
    $x = $startX+($i*$ScanRight)
    if ($x -lt 0 -or $x -ge $Dimension -or $y -lt 0 -or $y -ge $Dimension) {return}
    if ($Data[$y][$x] -ne $Search[$i]) {return}
  }
  $global:Result++
}

[int] $Result = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$Dimension = $Data.Length
$Search = 'XMAS'
$SearchLength = $Search.Length
for ($i = 0; $i -lt $Dimension*$Dimension; $i++) {
  $DivRem = [System.Math]::DivRem($i,$Dimension)
  $y = $DivRem.Item1
  $x = $DivRem.Item2
  MatchesSearchInGrid $y $x 0 1 # Right
  MatchesSearchInGrid $y $x 0 -1 # Left
  MatchesSearchInGrid $y $x 1 0 # Down
  MatchesSearchInGrid $y $x -1 0 # Up
  MatchesSearchInGrid $y $x 1 1 # Right Down
  MatchesSearchInGrid $y $x 1 -1 # Left Down
  MatchesSearchInGrid $y $x -1 1 # Right Up
  MatchesSearchInGrid $y $x -1 -1 # Left Up
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 2571 (18 for testdata)