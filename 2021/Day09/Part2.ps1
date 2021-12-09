Get-Variable | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

class Location {
    [int] $Row = 0 # Only used for debugging purposes
    [int] $Column = 0 # Only used for debugging purposes
    [int] $Value = 0
    [int] $LocationIndex = 0 # Used to identify this Location and connect it to Adjacent Locations and BasinIndex
    [int[]] $Adjacents = @()
    [bool] $IsLowestPoint = $false # Only used for calculating the RiskLevel for Part 1
    [int] $BasinIndex = -1 # -1 means not in a Basin yet, -2 means never in a Basin (Value 9)
    [int] RiskLevel() { if ($this.IsLowestPoint) { return 1 + $this.Value } else { return $null } } # For Part 1
}

# [string[]] $HeightMap = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $HeightMap = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

# Build up a Locations object and fill it up with the basic properties and the adjacents
$Rows = $HeightMap.Count
$Columns = $HeightMap[0].Length
$HeightMapValues = [int[]] $HeightMap.ToCharArray().ForEach( { $_.ToString() } )
$Locations = [Location[]]::New($HeightMapValues.Count)
for ($i = 0; $i -lt $HeightMapValues.Count; $i++) {
    $Location = [Location]::New()
    $Location.Row = [math]::Floor($i / $Columns)
    $Location.Column = $i % $Columns
    $Location.Value = $HeightMapValues[$i]
    $Location.LocationIndex = $i
    if ($Location.Row -ne 0) { $Location.Adjacents += $i - $Columns} # Above
    if ($Location.Column -ne 0) { $Location.Adjacents += $i - 1} # Left
    if ($Location.Column -ne $Columns - 1) { $Location.Adjacents += $i + 1} # Right
    if ($Location.Row -ne $Rows -1) { $Location.Adjacents += $i + $Columns} # Below
    $Locations[$i] = $Location
}

# Find the Lowest Points and set the BaseIndexes of those Lowest Points (and the highest points that should be ignored)
foreach ($Location in $Locations) {
    if ($Location.Value -lt ($Locations[$Location.Adjacents].Value | Measure-Object -Minimum).Minimum) {
        $Location.IsLowestPoint = $true
        $Location.BasinIndex = $Location.LocationIndex
    } else {
        if ($Location.Value -eq 9) { $Location.BasinIndex = -2 }
    }
}

# Keep looping through the locations that don't have a BasinIndex yet
$LocationsNotInBasin = $Locations.Where( {$_.BasinIndex -eq -1} )
while ($LocationsNotInBasin.Count -gt 0) {
    # Write-Host $Locations.Count, "locations with", $Locations.Where( {$_.IsLowestPoint} ).Count , "basins. Still this many locations to put in a basin:", $LocationsNotInBasin.Count
    foreach ($Location in $LocationsNotInBasin) {
        $BasinIndexOfAdjacents = ($Location.Adjacents.ForEach({$Locations[$_].BasinIndex}) | Measure-Object -Maximum).Maximum
        if ($BasinIndexOfAdjacents -gt -1) { $Location.BasinIndex = $BasinIndexOfAdjacents }
    }
    $LocationsNotInBasin = $LocationsNotInBasin.Where( {$_.BasinIndex -eq -1} )
}

$Top3 = $Locations | Group-Object -Property BasinIndex -NoElement | Where-Object -Property Name -ne -2 | Sort-Object -Property Count -Descending -Top 3 | Select-Object -ExpandProperty Count
Write-Host "Answer to Part 2:", ($Top3[0] * $Top3[1] * $Top3[2])
# Correct answer = 1076922 (1134 for testdata)
Write-Host "Answer to Part 1:", ($Locations.RiskLevel() | Measure-Object -Sum).Sum
# Correct answer = 562 (15 for testdata)