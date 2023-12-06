Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0
$BallLimits = @{'red'=12; 'green'=13; 'blue'=14}

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
foreach ($DataLine in $Data) {
  $GameValid = $true
  $Game, $AllBallData = $DataLine.Split(':').Trim()
  $GameBallData = $AllBallData.Split(';').Trim()
  foreach ($TurnBallData in $GameBallData.Split(',').Trim()) {
    $Amount, $Color = $TurnBallData.Split(' ')
    if ([int]$Amount -gt $BallLimits[$Color]) {$GameValid = $false}
  }
  if ($GameValid) {$Result += $Game.Split(' ')[1]}
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 2204 (8 for testdata)