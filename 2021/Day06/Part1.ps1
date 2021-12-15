Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Days = 80

# [System.Collections.ArrayList] $AgesInput = 3,4,3,1,2
[System.Collections.ArrayList] $AgesInput = [int[]] (Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop).Split(",")

for ([int] $DayCounter = 1 ; $DayCounter -le $Days ; $DayCounter++) {
    [int] $NewFishDayCounter = 0
    for ( [int] $i = 0 ; $i -lt $AgesInput.Count ; $i++) {
        if ($AgesInput[$i] -eq 0) {
            $AgesInput[$i] = 6
            $NewFishDayCounter++
        } else {
            $AgesInput[$i]--
        }
    }
    for ([int] $i = 1 ; $i -le $NewFishDayCounter ; $i++) {
        $AgesInput.Add(8) | Out-Null
    }
    Write-Host $DayCounter, $AgesInput.Count, "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
    # Correct answer = 351188 (5934 for testdata)
    $stopwatch.Restart()
}