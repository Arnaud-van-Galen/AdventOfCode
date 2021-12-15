Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

$CrabsGroup = @()
[int] $MinimumFuelCount = 0

# [int[]] $CrabsInput = 16,1,2,0,4,2,7,1,2,14
[int[]] $CrabsInput = [int[]] (Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop).Split(",")

$CrabsGroup = $CrabsInput | Group-Object -NoElement

for ([int] $Position = $CrabsGroup[0].Name ; $Position -le $CrabsGroup[-1].Name ; $Position++) {
    [int] $PositionFuelCount = 0
    foreach ($CrabGroup in $CrabsGroup) {
        [int] $Distance = [math]::Abs($Position - $CrabGroup.Name)
        if ($Distance -gt 0) { $PositionFuelCount += ($Distance + 1) * ($Distance / 2) * $CrabGroup.Count }
    }
    if ($MinimumFuelCount -eq 0 -or $PositionFuelCount -le $MinimumFuelCount) {
        $MinimumFuelCount = $PositionFuelCount
        # Write-Host "New Minimum FuelCount at Position: $Position. It is now: $MinimumFuelCount"
    } else { break }
}

Write-Host $MinimumFuelCount
# Correct answer = 99540554 (168 for testdata)