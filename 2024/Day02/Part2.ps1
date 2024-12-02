Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

foreach ($DataLine in $Data) {
  $Levels = $DataLine.Split(' ')
  $SafeAtLevel = $false
  for ($i = 0; $i -lt $Levels.Count; $i++) {
    $RelevantLevels = @()
    for ($j = 0; $j -lt $Levels.Count; $j++) {
      if ($j -ne $i) {$RelevantLevels += $Levels[$j]}
    }
    if ([int]$RelevantLevels[1] -lt [int]$RelevantLevels[0]) {[Array]::Reverse($RelevantLevels)} # Make sure the relevant levels should be increasing
    $SafeAtRelevantLevel = $true
    for ($k = 1; $k -lt $RelevantLevels.Count; $k++) {
      if ($RelevantLevels[$k] - $RelevantLevels[$k-1] -notin (1..3)) {
        $SafeAtRelevantLevel = $false
        continue
      }
    }
    if ($SafeAtRelevantLevel) {
      $SafeAtLevel = $true
      continue
    }
  }
  if ($SafeAtLevel) {$Result++}
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 710 (4 for testdata)