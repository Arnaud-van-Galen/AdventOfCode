Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

$Width = 0
$Height = 0
$MinValues = @{} # Key = $x,$y Value = Min($ValueOnTop, $ValueOnLeft)
$CaveIterations = 5

function Get-RiskValue { param ( [int] $X, [int] $Y )
    $OrgX = $X % $Width
    $OrgY = $Y % $Height
    $OrgRiskLevel = [int] $RiskLevels[$OrgY][$OrgX].ToString()
    $CurrentIterationX = [System.Math]::Floor($X / $Width + 1)
    $CurrentIterationY = [System.Math]::Floor($Y / $Height + 1)
    $RiskIncreases = $CurrentIterationX - 1 + $CurrentIterationY - 1
    $CurrentRiskLevel = ($OrgRiskLevel + $RiskIncreases) % 9 # 2 in grid 1,1 becomes 5 in grid 3,2 and 2,3. 8 becomes 2 after resetting to 9 once. 8 +13 becomes 3 after resetting twice
    if ($CurrentRiskLevel -eq 0) { $CurrentRiskLevel = 9 } # Reset to 1 after 9. ToDo: This only works for low cave-iterations that will not reset twice. Should be something like $CurrentRiskLevel % 9  8 + 5 becomes 
    # $MinValues[-join($OrgX, "," , $OrgY)]
    return [int] $CurrentRiskLevel
}
function Add-MinValue { param ( [int] $X, [int] $Y, [ValidateSet("Top", "Left", "Normal")] [string] $Kind)
    $ValueSelf = Get-RiskValue -X $X -Y $Y
    switch ($Kind) {
        "Top" { $MinValues[-join($X, "," ,$Y)] = $ValueSelf + $MinValues[-join(($X - 1), ",", $Y)] }
        "Left" { $MinValues[-join($X, ",", $Y)] = $ValueSelf + $MinValues[-join($X, ",", ($Y - 1))] }
        "Normal" { 
            $MinValue = ( $MinValues[-join(($X - 1), ",", $Y)], $MinValues[-join($X, ",", ($Y - 1))] ) | Measure-Object -Minimum | Select-Object -ExpandProperty Minimum
            $MinValues[-join($X, ",", $Y)] = $ValueSelf + $MinValue
        }
    }
}

# Pay attention when using RiskLevels[a][b]. a = y, b = x!
# $RiskLevels = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$RiskLevels = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$Width = $RiskLevels[0].Length
$Height = $RiskLevels.Count

$MinValues["0,0"] = 0 # TopLeft value doesn't count
for ($x = 1; $x -lt $Width * $CaveIterations; $x++) { Add-MinValue -X $x -Y 0 -Kind Top } # TopRow
for ($y = 1; $y -lt $Height * $CaveIterations; $y++) { Add-MinValue -X 0 -Y $y -Kind Left } # LeftColumn
for ($y = 1; $y -lt $Height * $CaveIterations; $y++) { # The rest of the grid
    for ($x = 1; $x -lt $Width * $CaveIterations; $x++) {
        Add-MinValue -X $x -Y $y -Kind Normal
    }
}

$MinValues[-join(($Width * $CaveIterations - 1), ",", ($Height * $CaveIterations - 1))]
# Correct answer = !2838 (315 for testdata)
# Get-MyVariables
# exit