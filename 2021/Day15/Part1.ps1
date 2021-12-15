Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

$Width = 0
$Height = 0
$MinValues = @{} # Key = $x,$y Value = Min($ValueOnTop, $ValueOnLeft)
function AddMinValue { param ( [int] $X, [int] $Y, [ValidateSet("Top", "Left", "Normal")] [string] $Kind)
    $ValueSelf = [int] $RiskLevels[$Y][$X].ToString()
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
for ($x = 1; $x -lt $Width; $x++) { AddMinValue -X $x -Y 0 -Kind Top } # TopRow
for ($y = 1; $y -lt $Height; $y++) { AddMinValue -X 0 -Y $y -Kind Left } # LeftColumn
for ($y = 1; $y -lt $Height; $y++) { # The rest of the grid
    for ($x = 1; $x -lt $Width; $x++) {
        AddMinValue -X $x -Y $y -Kind Normal
    }
}

$MinValues[-join(($Width - 1), ",", ($Height - 1))]
# Correct answer = 363 (40 for testdata)
# Get-MyVariables
# exit