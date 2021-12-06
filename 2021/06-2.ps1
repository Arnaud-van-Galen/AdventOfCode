$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $AgesInput = 3,4,3,1,2
$AgesInput = [int[]](Get-Content .\06-1-Input.txt).Split(",")
$AgesInputGrouped = $AgesInput | Group-Object -NoElement
$AllAgesCount = [Object[]]::new(9)
for ([int] $i = 0 ; $i -le 8 ; $i++) {
    $CountIndex = $AgesInputGrouped.Name.IndexOf($i.ToString())
    if ($CountIndex -ge 0) {
        $AllAgesCount[$i] = $AgesInputGrouped[$CountIndex].Count
    } else {
        $AllAgesCount[$i] = 0
    }
}
# Write-Host "After day 0: ", $AllAgesCount
# Write-Host "After day 0: ", ($AllAgesCount | Measure-Object -Sum).Sum
[int] $Days = 256

for ([int] $DayCounter = 1 ; $DayCounter -le $Days ; $DayCounter++) {
    $SpawnCounter = $AllAgesCount[0]
    $AllAgesCount[0] = 0
    for ( [int] $i = 1 ; $i -lt $AllAgesCount.Count ; $i++) {
         $AllAgesCount[$i-1] = $AllAgesCount[$i] }
    $AllAgesCount[6] += $SpawnCounter
    $AllAgesCount[8] = $SpawnCounter
    # Write-Host "After day $DayCounter :", $AllAgesCount
    # Write-Host "After day $DayCounter :", ($AllAgesCount | Measure-Object -Sum).Sum
}
Write-Host ($AllAgesCount | Measure-Object -Sum).Sum
# Correct answer = 1595779846729
Write-Host "Time for calculating: ", $stopwatch.Elapsed.TotalSeconds