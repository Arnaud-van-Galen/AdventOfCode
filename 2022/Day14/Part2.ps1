Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

$StartX = 500
$StartY = 0
$OccupiedPositions = @{}

# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

# Positions occupied by rock
foreach ($RockPath in $Data) {
    $RockLineBends = $RockPath.Split(" -> ")
    for ($RockLineBend = 0; $RockLineBend -lt $RockLineBends.Count - 1; $RockLineBend++) {
        $BeginX, $BeginY = $RockLineBends[$RockLineBend].Split(",")
        $EndX, $EndY = $RockLineBends[$RockLineBend + 1].Split(",")
        if ($BeginX -eq $EndX) {
            ($BeginY..$EndY).ForEach{ 
                if ($null -eq $OccupiedPositions["$BeginX,$_"]) {
                    $OccupiedPositions.Add("$BeginX,$_", "Rock")
                }
            }
        } else {
            ($BeginX..$EndX).ForEach{
                if ($null -eq $OccupiedPositions["$_,$BeginY"]) {
                    $OccupiedPositions.Add("$_,$BeginY", "Rock")
                }
            }
        }
    }
}

# Decide when to stop dropping sand
$FloorRow = ($occupiedPositions.Keys.ForEach{ $_.split(",")[1] } | Measure-Object -Maximum).Maximum + 2

$CurrentSandX, $CurrentSandY = $StartX, $StartY
do {
    if ($CurrentSandY -eq $FloorRow - 1) {
        $OccupiedPositions.Add("$CurrentSandX,$CurrentSandY", "Sand")
        $CurrentSandX, $CurrentSandY = $StartX, $StartY
    } elseif ($null -eq $OccupiedPositions["$CurrentSandX,$($CurrentSandY+1)"]) {
        $CurrentSandY++
    } elseif ($null -eq $OccupiedPositions["$($CurrentSandX-1),$($CurrentSandY+1)"]) {
        $CurrentSandX--
        $CurrentSandY++
    } elseif ($null -eq $OccupiedPositions["$($CurrentSandX+1),$($CurrentSandY+1)"]) {
        $CurrentSandX++
        $CurrentSandY++
    } else {
        $OccupiedPositions.Add("$CurrentSandX,$CurrentSandY", "Sand")
        $CurrentSandX, $CurrentSandY = $StartX, $StartY
    }
    } while ( $null -eq $OccupiedPositions["$StartX,$StartY"] )

$OccupiedPositions.Values.Where{$_ -eq "Sand"}.count
# Correct answer = 20870 (93 for testdata)

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds