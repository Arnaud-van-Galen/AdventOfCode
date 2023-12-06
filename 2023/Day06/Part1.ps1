Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[Int64] $Result = 1

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
$Times = [regex]::Matches($Data[0], '\d+').Value
$Distances = [regex]::Matches($Data[1], '\d+').Value
for ($i = 0; $i -lt $Times.Count; $i++) {
  $Time = $Times[$i]
  $Distance = $Distances[$i]
  $BeatCount = 0
  for ($hold = 1; $hold -lt $Time; $hold++) {
    if ($hold * ($Time-$hold) -gt $Distance) {$BeatCount++}
  }
  $Result = $Result * $BeatCount
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 2449062 (288 for testdata)