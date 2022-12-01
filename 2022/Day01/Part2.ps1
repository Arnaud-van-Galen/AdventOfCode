Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int[]] $MaxCalorieSums = @()
[int] $CurrentCalorieSum = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
$Data += ""

foreach ($CalorieValue in $Data) {
    $CurrentCalorieSum += $CalorieValue
    if ($CalorieValue -eq "") {
        $MaxCalorieSums += $CurrentCalorieSum
        $CurrentCalorieSum = 0
    }
}

Write-Host "the 3 Elfs carrying the most Calories in total are carrying $((($MaxCalorieSums | Sort-Object -Descending)[0..2] | Measure-Object -Sum).Sum) Calories"
# Correct answer = 207576 (45000 for testdata)