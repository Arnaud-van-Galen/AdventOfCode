Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

$WinLimit = 21
$CircleTrackSize = 10
$Player1StartPosition = 6 # 6 for real, 4 for test
$Player2StartPosition = 8 # 8 for real, 8 for test
$Player1Scores = , 0 * $WinLimit
$Player2Scores = , 0 * $WinLimit
$DieGroupSize = 3 # Number of dice is fixed at 3, Otherwise you have to add a $Throw4 loop
$DieSize = 3
$FrequencyTable = [Array[]]::new($CircleTrackSize) # $FrequencyToAdd # 1 3 6 7 6 3 1
for ($Row = 0; $Row -lt $CircleTrackSize; $Row++) {
    $FrequencyTable[$Row] = , 0 * $CircleTrackSize
}
foreach ($BeginPosition in (1..$CircleTrackSize)) {
    foreach ($Throw1 in (1..$DieSize)) {
        foreach ($Throw2 in (1..$DieSize)) {
            foreach ($Throw3 in (1..$DieSize)) {
                $DieTotal = $Throw1 + $Throw2 + $Throw3
                $EndPosition = $BeginPosition + $DieTotal
                while ($EndPosition -gt $CircleTrackSize) {$EndPosition -= $CircleTrackSize}
                $FrequencyTable[$BeginPosition-1][$EndPosition-1]++
            }
        }
    }
}
# Key=Position, Value=Points,Occurence
$EmptyStartScore = @{}
for ($i = 1; $i -le $CircleTrackSize; $i++) {
    [void] $EmptyStartScore.Add($i, @{})
}
# https://powershellexplained.com/2016-11-06-powershell-hashtable-everything-you-wanted-to-know-about/#deep-copies
function Get-DeepCloneHashTable { param ($InputObject)
        $clone = @{}
        foreach($key in $InputObject.keys) { $clone[$key] = Get-DeepCloneHashTable $InputObject[$key] }
        return $clone
}
$Player1Scores = Get-DeepCloneHashTable $EmptyStartScore
$Player2Scores = Get-DeepCloneHashTable $EmptyStartScore
$Player1Scores[$Player1StartPosition] = @{0 = 1}
$Player2Scores[$Player2StartPosition] = @{0 = 1}
$Player1AllScores = [System.Collections.ArrayList]::new()
$Player2AllScores = [System.Collections.ArrayList]::new()
[void] $Player1AllScores.Add($Player1Scores)
[void] $Player2AllScores.Add($Player2Scores)
$Player1WinningScores = [Int64] 0
$Player2WinningScores = [Int64] 0
while (($Player1AllScores[-1].Values.Values | Measure-Object -Sum).Sum -gt 0 -or ($Player2AllScores[-1].Values.Values | Measure-Object -Sum).Sum -gt 0) {
    $NewPlayer1Scores = Get-DeepCloneHashTable $EmptyStartScore
    $PreviousPlayer1Scores = $Player1AllScores[-1]
    $Player1RoundWinningScores = 0
    for ($OldPosition = 1; $OldPosition -le $CircleTrackSize; $OldPosition++) {
        foreach ($Point in $PreviousPlayer1Scores[$OldPosition].Keys) {
            for ($NewPosition = 1; $NewPosition -le $CircleTrackSize; $NewPosition++) {
                $NewPoints = $Point + $NewPosition
                $Occurence = $FrequencyTable[$OldPosition - 1][$NewPosition - 1] * $PreviousPlayer1Scores[$OldPosition][$Point]
                if ($Occurence -gt 0) {
                    if ($NewPoints -ge $WinLimit) {
                        # Write-Host "In round", $Player1AllScores.Count, "a score of", $NewPoints, "was reached by Player1 in", $Occurence, "universes on position", $NewPosition
                        $Player1RoundWinningScores += $Occurence
                    } else { $NewPlayer1Scores[$NewPosition][$NewPoints] += $Occurence }
                 }
            }    
        }
    }
    [void] $Player1AllScores.Add($NewPlayer1Scores)
    $Player1WinningScores += $Player1RoundWinningScores * ($Player2AllScores[-1].Values.Values | Measure-Object -Sum).Sum

    $NewPlayer2Scores = Get-DeepCloneHashTable $EmptyStartScore
    $PreviousPlayer2Scores = $Player2AllScores[-1]
    $Player2RoundWinningScores = 0
    for ($OldPosition = 1; $OldPosition -le $CircleTrackSize; $OldPosition++) {
        foreach ($Point in $PreviousPlayer2Scores[$OldPosition].Keys) {
            for ($NewPosition = 1; $NewPosition -le $CircleTrackSize; $NewPosition++) {
                $NewPoints = $Point + $NewPosition
                $Occurence = $FrequencyTable[$OldPosition - 1][$NewPosition - 1] * $PreviousPlayer2Scores[$OldPosition][$Point]
                if ($Occurence -gt 0) {
                    if ($NewPoints -ge $WinLimit) {
                        # Write-Host "In round", $Player2AllScores.Count, "a score of", $NewPoints, "was reached by Player2 in", $Occurence, "universes on position", $NewPosition
                        $Player2RoundWinningScores += $Occurence
                    } else { $NewPlayer2Scores[$NewPosition][$NewPoints] += $Occurence }
                }
            }    
        }
    }
    [void] $Player2AllScores.Add($NewPlayer2Scores)
    $Player2WinningScores += $Player2RoundWinningScores * ($Player1AllScores[-1].Values.Values | Measure-Object -Sum).Sum
}
(($Player1WinningScores, $Player2WinningScores) | Measure-Object -Maximum).Maximum
# Correct answer = 712381680443927 (444356092776315 voor testdata)