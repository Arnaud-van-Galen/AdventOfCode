Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

class Location {
    [int] $Row = 0 # Only used for debugging purposes
    [int] $Column = 0 # Only used for debugging purposes
    [int] $Value = 0 # S = 83, E = 69, a-z = 97-122
    [int] $LocationIndex = 0 # Used to identify this Location and connect it to Adjacent Locations
    [int[]] $Adjacents = @()
    [int] $ReachableIn = [int]::MaxValue
    [bool] $HasBeenTried = $false
}

# [string[]] $HeightMap = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $HeightMap = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

[int] $StartLocationIndex = (-join $HeightMap).IndexOf("S")
[int] $EndLocationIndex = (-join $HeightMap).IndexOf("E")
[int] $ResultToBeat = 440

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
        $LocationsToCheck = $Locations.Where{ $_.ReachableIn -ne [int]::MaxValue -and $_.HasBeenTried -eq $false }
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
        elseif ($RouteCounter -ge $MostScenicRouteLengthMin) { $RouteHasChanged = $false ; $Aborted = $true } # Will not become shorter than a previous route
        elseif ($RouteCounter -ge $ResultToBeat) { $RouteHasChanged = $false ; $Aborted = $true } # Will not become shorter than the result to beat. Time went from 435 to 420 seconds
    }
    
    $RoutesCounter++
    if ($Aborted) {
        Write-Host "$RoutesCounter of $($PossibleStartLocationIndexes.Count). Aborted"
    } elseif ($Locations[$EndLocationIndex].ReachableIn -eq [int]::MaxValue) {
        # Added optimization by disabling the locations that couldn't reach the end. Time went from 450 to 435 seconds
        $Locations.Where{ $_.ReachableIn -ne [int]::MaxValue }.ForEach{ $_.HasBeenTried = $true }
        Write-Host "$RoutesCounter of $($PossibleStartLocationIndexes.Count). End not reached"
    } else {
        $MostScenicRouteLengthMin = $Locations[$EndLocationIndex].ReachableIn
        Write-Host "$RoutesCounter of $($PossibleStartLocationIndexes.Count). From $StartLocationIndex you can reach the end in $MostScenicRouteLengthMin"
    }
}

$MostScenicRouteLengthMin
# Correct answer = 439 (29 for testdata)
# Naam: Part1, Part2
# Arnaud: 440, 439
# Aki: 504, 500
# Mike: 447, 446
# Niels: 484, 478

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds