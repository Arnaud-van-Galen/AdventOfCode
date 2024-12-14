Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

# $GridHeight, $GridWidth = (7,11)
$GridHeight, $GridWidth = (103,101)
$MoveCount = 0
[Int64]$Result = 1

while ($true) {
	$Drawing = [char[]]"."*$GridHeight*$GridWidth
	$Trunklength = 0
	$RobotsInQuadrant = @(0,0,0,0)
	$RobotsInCorner = @(0,0,0,0)
	foreach ($DataLine in $Data) {
		$x, $y, $vx, $vy = [int[]][regex]::Matches($DataLine, '-?\d+').Value
		$finalX = ($x + $vx * $MoveCount) % $GridWidth
		$finalY = ($y + $vy * $MoveCount) % $GridHeight
		if ($finalX -lt 0) {$finalX += $GridWidth}
		if ($finalY -lt 0) {$finalY += $GridHeight}

		if ($finalX -lt ($GridWidth-1)/2 -and $finalY -lt ($GridHeight-1)/2) {$RobotsInQuadrant[0]++}
		elseif ($finalX -gt ($GridWidth-1)/2 -and $finalY -lt ($GridHeight-1)/2) {$RobotsInQuadrant[1]++}
		elseif ($finalX -lt ($GridWidth-1)/2 -and $finalY -gt ($GridHeight-1)/2) {$RobotsInQuadrant[2]++}
		elseif ($finalX -gt ($GridWidth-1)/2 -and $finalY -gt ($GridHeight-1)/2) {$RobotsInQuadrant[3]++}
	
		if ($finalX -eq ($GridWidth-1)/2) {$Trunklength++}
		$Drawing[$finalY*$GridWidth+$finalX] = 'X'
	}
	"After $MoveCount seconds. TrunkLength is $Trunklength. Quadrants are $($robotsInQuadrant -join ', '). Top/Bottom distribution is $($RobotsInQuadrant[0]/$RobotsInQuadrant[2])"
	# Discover a method to only Draw when a possible christmas tree is discovered.
	# For example:
	#   "trunk" in the vertical middle $Trunklength -ge 0
	#   Righ-left symetry
	#   Empty top-corners
	# if ($RobotsInQuadrant[0]/$RobotsInQuadrant[1]*100 -in (95..105) -and $RobotsInQuadrant[2]/$RobotsInQuadrant[3]*100 -in (95..105) -and $RobotsInQuadrant[0]/$RobotsInQuadrant[2]*100 -notin (75..125)) {
	if ($RobotsInQuadrant[0]/$RobotsInQuadrant[2] -lt 0.75) {
		for ($i = 0; $i -lt $GridHeight; $i++) {
			$Drawing[($i*$GridWidth)..(($i+1)*$GridWidth-1)] -join ''
		}
    Read-Host "Press a key to continue"
	}
	$MoveCount++
}
# Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host "Calculated answer: $Result"
Write-Host "Correct answer: 224438715 (12 for testdata)"
Write-Host "To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('C:','/mnt/c').Replace('\','/'))"
Write-Host "To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('/mnt/c','C:').Replace('/','\'))"