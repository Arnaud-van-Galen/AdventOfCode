Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$Width = 0
$Height = 0
$CaveIterations = 5

class Location {
    [int] $LocationIndex = 0 # Used to identify this Location and connect it to Adjacent Locations
    [int] $RiskLevel = 0
    [int] $MinValue = [int]::MaxValue # 2147483647
    [int[]] $Adjacents = @()
    [bool] $ShouldRecalculate = $false
}

# $RiskLevels = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$RiskLevels = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$OriginalWidth = $RiskLevels[0].Length
$OriginalHeight = $RiskLevels.Count
$Width = $OriginalWidth * $CaveIterations
$Height = $OriginalHeight * $CaveIterations

# Build up a Locations object and fill it up with the basic properties and the adjacents
$Locations = [Location[]]::New($Width * $Height)
for ($i = 0; $i -lt $Locations.Count; $i++) {
    $Location = [Location]::New()
    $Location.LocationIndex = $i
    # Some examples will clarify what is happening here.
    # Lets say we want to know the RiskLevel of column 251 (x), row 343 (y) in a 100 (originalwidth) by 50 (originalheight) grid (yes, this code also works for non-square grids)
    # This risk-level will be based on column 51, row 43 in the original input (iteration 1). Let's assume that this value was 7
    # (Keep in mind that column 0 and row 0 also exist, so the original input would be [0..49][0..99] rows first, then columns)
    # Column 251 is the 3rd iteration (2 grids to the right) and row 343 is the 7nd iteration (6 grids down) so a total of 8 riskincreases have happened to this grid
    # All of that means that this will happen to that risklevel of 7: 7 (0), 8 (1), 9 (2), 1 (3), 2 (4), 3 (5), 4 (6), 5 (7), 6 (8). So it will become 6
    $Y = [math]::Floor($i / $Width)
    $X = $i % $Width
    $OrgX = $X % $OriginalWidth
    $OrgY = $Y % $OriginalHeight
    $OrgRiskLevel = [int] $RiskLevels[$OrgY][$OrgX].ToString()
    $CurrentIterationX = [System.Math]::Floor($X / $OriginalWidth + 1)
    $CurrentIterationY = [System.Math]::Floor($Y / $OriginalHeight + 1)
    $RiskIncreases = $CurrentIterationX - 1 + $CurrentIterationY - 1
    $CurrentRiskLevel = ($OrgRiskLevel + $RiskIncreases) % 9 # Reset to 1 after 9. This even works for resetting several times during big iteratations 8 after 13 riskincreases becomes 3.
    if ($CurrentRiskLevel -eq 0) { $CurrentRiskLevel = 9 } # 9 % 9 becomes 0 but should stay 9
    $Location.RiskLevel = $CurrentRiskLevel
    if ($Y -ne 0) { $Location.Adjacents += $i - $Width} # Above
    if ($X -ne 0) { $Location.Adjacents += $i - 1} # Left
    if ($X -ne $Width - 1) { $Location.Adjacents += $i + 1} # Right
    if ($Y -ne $Height -1) { $Location.Adjacents += $i + $Width} # Below
    $Locations[$i] = $Location
}

# Set initial values
$Locations[0].MinValue = 0 # TopLeft value doesn't count
for ($i = 1; $i -lt $Locations.Count; $i++) {
    $AdjacentsMinValue = $Locations[$i].Adjacents.ForEach{$Locations[$_].MinValue} | Measure-Object -Minimum | Select-Object -ExpandProperty Minimum
    if ($Locations[$i].MinValue -eq [int]::MaxValue -or $Locations[$i].MinValue - $Locations[$i].RiskLevel -gt $AdjacentsMinValue) {
        $Locations[$i].MinValue = $AdjacentsMinValue + $Locations[$i].RiskLevel
        $Locations[$i].Adjacents.ForEach{$Locations[$_].ShouldRecalculate = $true}
    }
}
Write-Host "Time for calculating until the initial value set:", $stopwatch.Elapsed.TotalSeconds, "MinValue:", $Locations[-1].MinValue
$stopwatch.Restart()

$Optimal = $false
$IterationsCount = 0
while (!$Optimal) {
    $Optimal = $true
    $IterationsCount++
    $ChangesCount = 0
    $RecalculateLocations = $Locations.Where{$_.ShouldRecalculate -eq $true }
    $RecalculateLocations.ForEach{$_.ShouldRecalculate = $false}
    foreach ($Location in $RecalculateLocations) {
        $AdjacentsMinValue = $Location.Adjacents.ForEach{$Locations[$_].MinValue} | Measure-Object -Minimum | Select-Object -ExpandProperty Minimum
        if ($Location.MinValue -eq [int]::MaxValue -or $Location.MinValue - $Location.RiskLevel -gt $AdjacentsMinValue) {
            $Location.MinValue = $AdjacentsMinValue + $Location.RiskLevel
            $Location.Adjacents.ForEach{$Locations[$_].ShouldRecalculate = $true}
            $Optimal = $false
            $ChangesCount++
    }
    }
    Write-Host "IterationsCount:", $IterationsCount,"RecalculationsCount:", $RecalculateLocations.Count, "ChangesCount:", $ChangesCount, "Time for calculating:", $stopwatch.Elapsed.TotalSeconds, "MinValue:", $Locations[-1].MinValue
    $stopwatch.Restart()
}

$Locations[-1].MinValue
# Correct answer = 2835 (315 for testdata)