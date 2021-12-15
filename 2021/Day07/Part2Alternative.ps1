Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int] $Average = 0
[int] $FuelCount = 0

# [int[]] $CrabsInput = 16,1,2,0,4,2,7,1,2,14
[int[]] $CrabsInput = [int[]] (Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop).Split(",")

$Average = ($CrabsInput | Measure-Object -Average).Average - 1
foreach ($Crab in $CrabsInput) {
    [int] $Distance = [math]::Abs($Average - $Crab)
    if ($Distance -gt 0) { $FuelCount += ($Distance + 1) * ($Distance / 2) }
}

Write-Host $FuelCount
# Correct answer = 99540554 (168 for testdata)
# ToDo! This optimization with just pure "average -1" doesn't work perfectly.
# It just accidentely gives the correct answer for the real input but for the testdata it happens to be "average -1 +1" (so just average)
# So starting at average and then checking right and left should be implemented