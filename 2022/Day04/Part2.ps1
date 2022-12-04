Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int] $OverlappingSum = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

foreach ($AssignmentPair in $Data) {
    [int] $min1, [int] $max1, [int] $min2, [int] $max2 = $AssignmentPair.Split("-,".ToCharArray())
    if (!($max1 -lt $min2 -or $max2 -lt $min1)) {
        $OverlappingSum++
    }
}

Write-Host "$OverlappingSum"
# Correct answer = 779 (4 for testdata)