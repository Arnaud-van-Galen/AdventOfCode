Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
$Search = 'XMAS'
for ($y = 0; $y -lt $Data.Length; $y++) {
  for ($x = 0; $x -lt $Data[0].Length; $x++) {
    if ($Data[$y][$x] -ne $Search[0]) {continue} # We are starting at an X
    foreach($v in (-1,0,1)) {
      foreach($h in (-1,0,1)) {
        if ($v -eq 0 -and $h -eq 0) {continue} # We are moving
        for ($i = $Search.Length-1; $i -ge 1; $i--) {
          $testY = $y+($i*$v) ; if ($testY -lt 0) {break} # We didn't move vertically above the grid
          $testX = $x+($i*$h) ; if ($testX -lt 0) {break} # We didn't move horizontally left of the grid
          if ($Data[$testY]?[$testX] -ne $Search[$i]) {break} # We are still matching
        }
        if ($i -eq 0) {$Result++}
      }
    }
  }
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 2571 (18 for testdata)