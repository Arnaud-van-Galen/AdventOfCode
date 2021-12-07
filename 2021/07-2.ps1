$CrabsGroup = @()
[int] $MinimumFuelCount = 0
# [int[]] $CrabsInput = 16,1,2,0,4,2,7,1,2,14
[int[]] $CrabsInput = [int[]] (Get-Content .\07-1-Input.txt).Split(",")

$CrabsGroup = $CrabsInput | Group-Object -NoElement

for ([int] $Position = $CrabsGroup[0].Name ; $Position -le $CrabsGroup[-1].Name ; $Position++) {
    [int] $PositionFuelCount = 0
    foreach ($CrabGroup in $CrabsGroup) {
        [int] $Distance = [math]::Abs($Position - $CrabGroup.Name)
        if ($Distance -gt 0) {
            $PositionFuelCount += ($Distance+1) * ($Distance/2) * $CrabGroup.Count
        }
    }
    if ($MinimumFuelCount -eq 0 -or $PositionFuelCount -le $MinimumFuelCount) {
        $MinimumFuelCount = $PositionFuelCount
        Write-Host "New Minimum FuelCount at Position: $Position. It is now: $MinimumFuelCount"
    }
    # Correct answer = 349769
}