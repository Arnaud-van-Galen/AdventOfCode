Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
# $GridSize = 7 # (0 to 6 = 7 for testdata, 0 to 70 = 71 for real data)
# $BytesFallen = 12 # (12 for testdata, 1024 for real data)
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
$GridSize = 71 # (0 to 6 = 7 for testdata, 0 to 70 = 71 for real data)
$BytesFallen = 2993 # (12 for testdata, 1024 for real data). Found by "halving" the difference and seeing if $Data[$EndIndex] -lt intmaxvalue. Should be easy to program and probably fastest from the back

$GridHeight = $GridSize
$GridWidth = $GridSize
$Directions = (-1,0),(0,1),(1,0),(0,-1)

[char[]]$Map = '.' * $GridHeight * $GridWidth
for ($i = 0; $i -lt $BytesFallen; $i++) {
	$X, $Y = [int[]]$Data[$i].Split(',')
	$Map[$Y * $GridWidth + $X] = [char]'#'
}
for ($d = 0; $d -lt $GridHeight; $d++) { ($Map[($d*$GridWidth)..(($d+1)*$GridWidth-1)] -join '').Replace('O', "`e[31mO`e[0m") }


$EndIndex = $GridHeight * $GridWidth - 1
$TotalStepsNeeded = [int]::MaxValue
$Progress = @([int]::MaxValue)*$GridHeight*$GridWidth
$MazeSearcher = [System.Collections.Stack]::new() # Keep track of Position and StepsNeeded
$MazeSearcher.Push((0, 0))
While ($MazeSearcher.Count -gt 0) {
	$Position, $StepsNeeded = $MazeSearcher.Pop()
	if ($Progress[$Position] -gt $StepsNeeded -and $StepsNeeded -lt $TotalStepsNeeded) { # We came here in the best way so far and might improve on the best route
		if ($Position -eq $EndIndex) {$TotalStepsNeeded = $StepsNeeded; $TotalStepsNeeded}
		$DivRem = [System.Math]::DivRem($Position, $GridWidth)
		$Y, $X = $DivRem.Item1, $DivRem.Item2
		$Progress[$Position] = $StepsNeeded
		foreach ($Direction in $Directions) {
			$NeighbourY = $Y + $Direction[0]
			$NeighbourX = $X + $Direction[1]
			$NeighbourPosition = $NeighbourY * $GridWidth + $NeighbourX
			if ($NeighbourY -lt 0 -or $NeighbourY -ge $GridHeight -or $NeighbourX -lt 0 -or $NeighbourX -ge $GridWidth) { continue } # Don't go offgrid
			if ($Map[$NeighbourPosition] -eq '#') { continue } # Cannot walk on walls
			if ($Progress[$NeighbourPosition] -le $StepsNeeded + 1) { continue } # We didn't come here in a better way
			$MazeSearcher.Push(($NeighbourPosition, ($StepsNeeded + 1)))
		}
	}
}

# Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host "Calculated answer: $($Data[$BytesFallen-1])"
Write-Host "Correct answer: ??? (XXX for testdata)"
Write-Host "To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('C:','/mnt/c').Replace('\','/'))"
Write-Host "To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('/mnt/c','C:').Replace('/','\'))"