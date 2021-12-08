Get-Variable | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

$AllAgesCount = [Object[]]::new(9)
[int] $Days = 256

# $AgesInput = 3,4,3,1,2
$AgesInput = [int[]] (Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop).Split(",")

($AgesInput | Group-Object -NoElement).ForEach( { $AllAgesCount[$_.Name] = $_.Count } )
# Write-Host "After day 0:", ($AllAgesCount | Measure-Object -Sum).Sum, "fish distributed like:", $AllAgesCount

for ([int] $DayCounter = 1 ; $DayCounter -le $Days ; $DayCounter++) {
    $SpawnCounter = $AllAgesCount[0]
    $AllAgesCount[0] = 0
    for ([int] $i = 1 ; $i -lt $AllAgesCount.Count ; $i++) {
         $AllAgesCount[$i-1] = $AllAgesCount[$i]
    }
    $AllAgesCount[6] += $SpawnCounter
    $AllAgesCount[8] = $SpawnCounter
    # Write-Host "After day $($DayCounter):", ($AllAgesCount | Measure-Object -Sum).Sum, "fish distributed like:", $AllAgesCount
}

Write-Host ($AllAgesCount | Measure-Object -Sum).Sum
# Correct answer = 1595779846729 (26984457539 for testdata)
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds