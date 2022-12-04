Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int] $OverlappingSum = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

foreach ($AssignmentPair in $Data) {
    [int] $min1, [int] $max1, [int] $min2, [int] $max2 = $AssignmentPair.Split("-,".ToCharArray())
    if (($min1 -le $min2 -and $max1 -ge $max2) -or ($min2 -le $min1 -and $max2 -ge $max1)) {
        $OverlappingSum++
    }
}

Write-Host "$OverlappingSum"
# Correct answer = 459 (2 for testdata)