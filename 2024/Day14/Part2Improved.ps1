Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

# $GridHeight, $GridWidth = (7,11)
$GridHeight, $GridWidth = (103,101)
$MoveCount = 0
$NonRandoms = @() # By keeping track of the interval of when "not just random data" appears we can greatly improve the detection speed

while ($true) {
	$RobotsInVerticalLines = [int[]](0)*$GridWidth
	$Drawing = [char[]]" "*$GridHeight*$GridWidth # Empty drawgrid
	foreach ($DataLine in $Data) {
		$x, $y, $vx, $vy = [int[]][regex]::Matches($DataLine, '-?\d+').Value
		$finalX = ($x + $vx * $MoveCount) % $GridWidth
		$finalY = ($y + $vy * $MoveCount) % $GridHeight
		if ($finalX -lt 0) {$finalX += $GridWidth}
		if ($finalY -lt 0) {$finalY += $GridHeight}
		$RobotsInVerticalLines[$finalX]++
		$Drawing[$finalY*$GridWidth+$finalX] = 'X' # Mark a Drone
	}
	$VerticalDistribution = ($RobotsInVerticalLines | Measure-Object -StandardDeviation).StandardDeviation  # -gt 3 is a good indicator that the data is not random
	Write-Host "After $MoveCount seconds vertical line distribution is $VerticalDistribution"
	if ($VerticalDistribution -gt 3) {
		if ($NonRandoms.Count -lt 2) {$NonRandoms += $MoveCount}
		for ($i = 0; $i -lt $GridHeight; $i++) { $Drawing[($i*$GridWidth)..(($i+1)*$GridWidth-1)] -join '' }
		$HorizontalBarDetection = ([regex]::Matches($Drawing -join '', 'X+').Length | Measure-Object -Maximum).Maximum # -gt 10 means that the tree is found
		if ($HorizontalBarDetection -gt 10) { break }
	}
	if ($NonRandoms.Count -ne 2) {$MoveCount++} else {$MoveCount+= $NonRandoms[1]-$NonRandoms[0]} # Interval determined, speeding up detection
}
# Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host "Calculated answer: $MoveCount"
Write-Host "Correct answer: 7603"
Write-Host "To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('C:','/mnt/c').Replace('\','/'))"
Write-Host "To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('/mnt/c','C:').Replace('/','\'))"