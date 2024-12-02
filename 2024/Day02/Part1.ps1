Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

foreach ($DataLine in $Data) {
  $Levels = $DataLine.Split(' ')
  if ([int]$Levels[1] -lt [int]$Levels[0]) {[Array]::Reverse($Levels)} # Make sure the levels should be increasing
  $Safe = $true
  for ($i = 1; $i -lt $Levels.Count; $i++) {
    if ($Levels[$i] - $Levels[$i-1] -notin (1..3)) {
      $Safe = $false
      continue
    }
  }
  if ($Safe) {$Result++}
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 680 (2 for testdata)