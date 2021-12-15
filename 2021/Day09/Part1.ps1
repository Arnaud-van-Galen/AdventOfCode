Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int] $RiskLevelSum = 0

# [string[]] $HeightMap = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $HeightMap = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$Rows = $HeightMap.Count
$Columns = $HeightMap[0].Length

for ($y = 0; $y -lt $Rows; $y++) {
    for ($x = 0 ; $x -lt $Columns ; $x++) {
        [int[]] $Adjacents = @()
        if ($x -gt 0) { $Adjacents += [int] $HeightMap[$y].ToCharArray()[$x - 1].ToString() } # left
        if ($x -lt $Columns - 1) { $Adjacents += [int] $HeightMap[$y].ToCharArray()[$x + 1].ToString() } # right
        if ($y -gt 0) { $Adjacents += [int] $HeightMap[$y - 1].ToCharArray()[$x].ToString() } # above
        if ($y -lt $Rows - 1) { $Adjacents += [int] $HeightMap[$y + 1].ToCharArray()[$x].ToString() } # belowe
        $Current = [int] $HeightMap[$y].ToCharArray()[$x].ToString()
        if ($Current -lt ($Adjacents | Measure-Object -Minimum).Minimum ) { 
            $RiskLevelSum += $Current + 1 
        }
    }
}

$RiskLevelSum
# Correct answer = 562 (15 for testdata)