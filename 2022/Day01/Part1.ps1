Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int] $MaxCalorieSum = 0
[int] $CurrentCalorieSum = 0

# $Data = Get-Content -Path $PSScriptRoot\Data1-Sample.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data1.txt -ErrorAction Stop
$Data += ""

foreach ($CalorieValue in $Data) {
    $CurrentCalorieSum += $CalorieValue
    if ($CalorieValue -eq "") {
        if ($CurrentCalorieSum -gt $MaxCalorieSum) {
            $MaxCalorieSum = $CurrentCalorieSum
        }
        $CurrentCalorieSum = 0
    }
}

Write-Host "the Elf carrying the most Calories is carrying $MaxCalorieSum Calories"
# Correct answer = 69883 (24000 for testdata)