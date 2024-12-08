Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$GridWidth = $Data.Length
$GridHeight = $Data[0].Length
$Antennas = [regex]::Matches($Data -join '', '[a-zA-Z0-9]')
$GroupedAntennas = ($Antennas | Group-Object -CaseSensitive).Where{$_.Count -gt 1}

$Antinodes+=@{}
foreach ($AntennaGroup in $GroupedAntennas) {
	$Amount = $AntennaGroup.Count
	for ($first = 0; $first -lt $Amount-1; $first++) {
		for ($second = $first+1; $second -lt $Amount; $second++) {
			$FirstAntenna = [System.Math]::DivRem($AntennaGroup.Group[$first].Index, $GridWidth)
			$SecondAntenna = [System.Math]::DivRem($AntennaGroup.Group[$second].Index, $GridWidth)
			$yDif = $SecondAntenna.Item1-$FirstAntenna.Item1
			$xDif = $SecondAntenna.Item2-$FirstAntenna.Item2

			$y, $x = @(($FirstAntenna.Item1), ($FirstAntenna.Item2))
			while ($y -ge 0 -and $y -lt $GridHeight -and $x -ge 0 -and $x -lt $GridWidth) {
				$Antinodes[$y*$GridHeight+$x]++
				$y, $x = @(($y-$yDif), ($x-$xDif))
			}

			$y, $x = @(($SecondAntenna.Item1), ($SecondAntenna.Item2))
			while ($y -ge 0 -and $y -lt $GridHeight -and $x -ge 0 -and $x -lt $GridWidth) {
				$Antinodes[$y*$GridHeight+$x]++
				$y, $x = @(($y+$yDif), ($x+$xDif))
			}
		}
	}
}

# Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Antinodes.Count
# Correct answer = 1182 (34 for testdata)