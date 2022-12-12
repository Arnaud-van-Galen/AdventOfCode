Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

class Location {
    [int] $Row = 0 # Only used for debugging purposes
    [int] $Column = 0 # Only used for debugging purposes
    [int] $Value = 0 # S = 83, E = 69, a-z = 97-122
    [int] $LocationIndex = 0 # Used to identify this Location and connect it to Adjacent Locations and BasinIndex
    [int[]] $Adjacents = @()
    [int] $ReachableIn = [int]::MaxValue
}

# [string[]] $HeightMap = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $HeightMap = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

[int] $StartLocationIndex = (-join $HeightMap).IndexOf("S")
[int] $EndLocationIndex = (-join $HeightMap).IndexOf("E")

# Build up a Locations object and fill it up with the basic properties and the adjacents
$Rows = $HeightMap.Count
$Columns = $HeightMap[0].Length
$HeightMapValues = [int[]] $HeightMap.ToCharArray()
$HeightMapValues[$StartLocationIndex] = "a"[0]
$HeightMapValues[$EndLocationIndex] = "z"[0]
$Locations = [Location[]]::New($HeightMapValues.Count)
for ($i = 0; $i -lt $HeightMapValues.Count; $i++) {
    $Location = [Location]::New()
    $Location.Row = [math]::Floor($i / $Columns)
    $Location.Column = $i % $Columns
    $Location.Value = $HeightMapValues[$i]
    $Location.LocationIndex = $i
    # Added optimization to not move from "a" to "a". Time went from 842 to 450 seconds
    if ($Location.Row -ne 0 -and $HeightMapValues[$i - $Columns] - $HeightMapValues[$i] -le 1 -and $HeightMapValues[$i - $Columns -ne "a"[0]]) {  $Location.Adjacents += $i - $Columns } # Above if reachable
    if ($Location.Column -ne 0 -and $HeightMapValues[$i - 1] - $HeightMapValues[$i] -le 1 -and $HeightMapValues[$i - 1] -ne "a"[0]) { $Location.Adjacents += $i - 1 } # Left if reachable
    if ($Location.Column -ne $Columns - 1 -and $HeightMapValues[$i + 1] - $HeightMapValues[$i] -le 1 -and $HeightMapValues[$i + 1] -ne "a"[0]) { $Location.Adjacents += $i + 1 } # Right if reachable
    if ($Location.Row -ne $Rows -1 -and $HeightMapValues[$i + $Columns] - $HeightMapValues[$i] -le 1 -and $HeightMapValues[$i + $Columns] -ne "a"[0]) { $Location.Adjacents += $i + $Columns } # Below if reachable
    $Locations[$i] = $Location
}

$MostScenicRouteLengthMin = [int]::MaxValue
$RoutesCounter = 0
$PossibleStartLocationIndexes = ($Locations.Where{ $_.Value -eq "a"[0] }).LocationIndex
foreach ($PossibleStartLocationIndex in $PossibleStartLocationIndexes) {
    $Locations.ForEach{ $_.ReachableIn=[int]::MaxValue }
    $StartLocationIndex = $PossibleStartLocationIndex
    $Locations[$StartLocationIndex].ReachableIn = 0
    $RouteCounter = 0 ; $Aborted = $false
    $RouteHasChanged = $true
    while ($RouteHasChanged) {
        $RouteHasChanged = $false
        $LocationsToCheck = $Locations.Where{ $_.ReachableIn -ne [int]::MaxValue }
        foreach ($LocationToCheck in $LocationsToCheck) {
            foreach ($AdjacentLocationIndex in $LocationToCheck.Adjacents) {
                $AdjacentLocation = $Locations[$AdjacentLocationIndex]
                if ($LocationToCheck.ReachableIn + 1 -lt $AdjacentLocation.ReachableIn) {
                    $AdjacentLocation.ReachableIn = $LocationToCheck.ReachableIn + 1
                    $RouteHasChanged = $true
                }
            }
        }
        $RouteCounter++
        # Write-Host "After $RouteCounter RouteChanges the end is reachable in $($Locations[$EndLocationIndex].ReachableIn)"
        if ($RouteCounter -ge $Locations[$EndLocationIndex].ReachableIn) { $RouteHasChanged = $false } # Already optimal
        if ($RouteCounter -ge $MostScenicRouteLengthMin) { $RouteHasChanged = $false ; $Aborted = $true } # Will not become shorter than a previous route
    }
    $RoutesCounter++
    if ($Aborted -or $Locations[$EndLocationIndex].ReachableIn -eq [int]::MaxValue) {
        Write-Host "$RoutesCounter of $($PossibleStartLocationIndexes.Count). Aborted or End not reached"
    } else {
        $MostScenicRouteLengthMin = $Locations[$EndLocationIndex].ReachableIn
        Write-Host "$RoutesCounter of $($PossibleStartLocationIndexes.Count). From $StartLocationIndex you can reach the end in $MostScenicRouteLengthMin"
    }
}
$MostScenicRouteLengthMin
# Correct answer = 439 (29 for testdata)

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds