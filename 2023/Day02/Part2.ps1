Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int] $Result = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
foreach ($DataLine in $Data) {
  $BallLimits = @{'red'=0; 'green'=0; 'blue'=0}
  $Game, $AllBallData = $DataLine.Split(':').Trim()
  $GameBallData = $AllBallData.Split(';').Trim()
  foreach ($TurnBallData in $GameBallData.Split(',').Trim()) {
    $Amount, $Color = $TurnBallData.Split(' ')
    if ([int]$Amount -gt $BallLimits[$Color]) {$BallLimits[$Color] = $Amount}
  }
  $Power = 1
  $BallLimits.Values.ForEach{$Power = $Power * $_}
  $Result += $Power
}

Write-Host $Result
# Correct answer = 71036 (2286 for testdata)