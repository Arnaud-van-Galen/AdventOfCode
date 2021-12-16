Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
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
    $CurrentRiskLevel = ($OrgRiskLevel + $RiskIncreases) % 9 # Reset to 1 after 9. This even works for resetting several times during big iteratations 8 after 13 riskincreases becomes 3.
    if ($CurrentRiskLevel -eq 0) { $CurrentRiskLevel = 9 } # 9 % 9 becomes 0 but should stay 9
    return $CurrentRiskLevel
    # Some examples will clarify what is happening here.
    # Lets say we want to know the RiskLevel of column 251 (x), row 343 (y) in a 100 (width) by 50 (height) grid (yes, this code also works for non-square grids)
    # This risk-level will be based on column 51, row 43 in the original input (iteration 1). Let's assume that this value was 7
    # (Keep in mind that column 0 and row 0 also exist, so the original input would be [0..49][0..99] rows first, then columns)
    # Column 251 is the 3rd iteration (2 grids to the right) and row 343 is the 7nd iteration (6 grids down) so a total of 8 riskincreases have happened to this grid
    # All of that means that this will happen to that risklevel of 7: 7 (0), 8 (1), 9 (2), 1 (3), 2 (4), 3 (5), 4 (6), 5 (7), 6 (8). So it will become 6
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
$RiskLevels = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
# $RiskLevels = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

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
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds