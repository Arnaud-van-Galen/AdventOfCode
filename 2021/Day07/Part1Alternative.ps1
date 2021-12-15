Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int] $Median = 0
[int] $FuelCount = 0

# [int[]] $CrabsInput = 16,1,2,0,4,2,7,1,2,14 | Sort-Object
[int[]] $CrabsInput = [int[]] (Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop).Split(",") | Sort-Object

$Median = $CrabsInput[$CrabsInput.Count / 2]
foreach ($Crab in $CrabsInput) {
    $FuelCount += [math]::Abs($median - $Crab)
}

Write-Host $FuelCount
# Correct answer = 349769 (37 for testdata)

# Optimization not used because median seemed to work just fine: https://www.geeksforgeeks.org/maximum-subarray-sum-using-divide-and-conquer-algorithm/