Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

# $FileData = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
# $FileData = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$DieSize = 100
$Player1Position = 6 # 6
$Player2Position = 8 # 8
$DieGroupSize = 3
$CircleTrackSize = 10

$Player1Score = 0
$Player2Score = 0
$DieStart = 0
while ($Player1Score -lt 1000 -and $Player2Score -lt 1000) {
    $TurnValue = 0
    for ($i = 1; $i -le $DieGroupSize; $i++) {
        $DieValue = ($DieStart + $i) % $DieSize
        if ($DieValue -eq 0) { $DieValue = $DieSize}
        Write-Host "Die started at $DieStart so adding", $DieValue 
        $TurnValue += ($DieStart + $i) % $DieSize
    }
    Write-Host "TurnValue:", $TurnValue, "Players are at positions:", $Player1Position, $Player2Position, "and have these scores:", $Player1Score, $Player2Score
    if (($DieStart / $DieGroupSize) % 2 -eq 0) {
        $Player1Position = ($Player1Position + $TurnValue) % $CircleTrackSize
        if ($Player1Position -eq 0) { $Player1Position = $CircleTrackSize }
        $Player1Score += $Player1Position
        Write-Host "Player1 Played. Players are at positions:", $Player1Position, $Player2Position, "and have these scores:", $Player1Score, $Player2Score
    } else {
        $Player2Position = ($Player2Position + $TurnValue) % $CircleTrackSize
        if ($Player2Position -eq 0) { $Player2Position = $CircleTrackSize }
        $Player2Score += $Player2Position
        Write-Host "Player2 Played. Players are at positions:", $Player1Position, $Player2Position, "and have these scores:", $Player1Score, $Player2Score
    }
    $DieStart += $DieGroupSize
}
$DieStart * (($Player1Score,$Player2Score) | Measure-Object -Minimum).Minimum
# Write-Host "Het resultaat was:", $WholePairSet
# Correct answer = 3793 (739785 voor testdata)