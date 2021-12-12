Get-Variable | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

class Octopus {
    [int] $Row = 0 # Only used for debugging purposes
    [int] $Column = 0 # Only used for debugging purposes
    [int] $EnergyLevel = 0
    [int] $OctopusIndex = 0 # Used to identify this Octopus and connect it to Adjacent Octopuses
    [int[]] $Adjacents = @()
    [bool] $HasFlashed = $false
    [bool] ShouldStillFlash() { return ($this.EnergyLevel -gt 9 -and !$this.HasFlashed) }
}
$StepsCount = 0

# [string[]] $EnergyLevels = Get-Content -Path $PSScriptRoot\DataDemo2.txt -ErrorAction Stop
[string[]] $EnergyLevels = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

# Build up a Octopuses object and fill it up with the basic properties and the adjacents
$Rows = $EnergyLevels.Count
$Columns = $EnergyLevels[0].Length
$EnergyLevelValues = [int[]] $EnergyLevels.ToCharArray().ForEach( { $_.ToString() } )
$Octopuses = [Octopus[]]::New($EnergyLevelValues.Count)
for ($i = 0; $i -lt $EnergyLevelValues.Count; $i++) {
    $Octopus = [Octopus]::New()
    $Octopus.Row = [math]::Floor($i / $Columns)
    $Octopus.Column = $i % $Columns
    $Octopus.EnergyLevel = $EnergyLevelValues[$i]
    $Octopus.OctopusIndex = $i
    if ($Octopus.Column -ne 0 -and $Octopus.Row -ne 0) { $Octopus.Adjacents += $i - 1 - $Columns} # LeftAbove
    if ($Octopus.Row -ne 0) { $Octopus.Adjacents += $i - $Columns} # Above
    if ($Octopus.Column -ne $Columns - 1 -and $Octopus.Row -ne 0) { $Octopus.Adjacents += $i + 1 - $Columns} # RightAbove
    if ($Octopus.Column -ne 0) { $Octopus.Adjacents += $i - 1} # Left
    if ($Octopus.Column -ne $Columns - 1) { $Octopus.Adjacents += $i + 1} # Right
    if ($Octopus.Column -ne 0 -and $Octopus.Row -ne $Rows -1) { $Octopus.Adjacents += $i - 1 + $Columns} # LeftBelow
    if ($Octopus.Row -ne $Rows -1) { $Octopus.Adjacents += $i + $Columns} # Below
    if ($Octopus.Column -ne $Columns - 1 -and $Octopus.Row -ne $Rows -1) { $Octopus.Adjacents += $i + 1 + $Columns} # RightBelow
    $Octopuses[$i] = $Octopus
}

while ($Octopuses.Where{$_.EnergyLevel -eq 0}.Count -ne $Octopuses.Count) {
    # First, the energy level of each octopus increases by 1.
    foreach ($Octopus in $Octopuses) {
        $Octopus.EnergyLevel++
        $Octopus.HasFlashed = $false
    }
    # Then, any octopus with an energy level greater than 9 flashes. This increases the energy level of all adjacent octopuses by 1
    while ($Octopuses.Where{$_.ShouldStillFlash()}.Count -gt 0) {
        foreach ($Octopus in $Octopuses) {
            if ($Octopus.ShouldStillFlash()) {
                foreach ($Adjacent in $Octopus.Adjacents) {
                    $Octopuses[$Adjacent].EnergyLevel++
                }
                $Octopus.HasFlashed = $true
            }
        } 
    }
    # Finally, any octopus that flashed during this step has its energy level set to 0
    foreach ($Octopus in $Octopuses) {
        if ($Octopus.HasFlashed) {
            $Octopus.EnergyLevel = 0
        }
    }
    $StepsCount++
}

$StepsCount
# Correct answer = 298 (195 for testdata)