Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$GridHeight, $GridWidth = (103,101)
$MoveCount = 0
[Int64]$Result = 1
$MinSafety = [System.Math]::Pow($Data.Count/4, 4)
$MinMoveCount = $MoveCount
$RepeatCheck = ''
$Drones = [int[]][regex]::Matches($Data, '-?\d+').Value

while ($true) {
	$RobotsInQuadrant = @(0,0,0,0)
	for ($i = 0; $i -lt $Drones.Count; $i+=4) {
		$x,$y,$vx,$vy = $Drones[$i..($i+4-1)]
		$finalX = ($x + $vx * $MoveCount) % $GridWidth
		$finalY = ($y + $vy * $MoveCount) % $GridHeight
		if ($finalX -lt 0) {$finalX += $GridWidth}
		if ($finalY -lt 0) {$finalY += $GridHeight}
		
		if ($finalX -lt ($GridWidth-1)/2 -and $finalY -lt ($GridHeight-1)/2) {$RobotsInQuadrant[0]++}
		elseif ($finalX -gt ($GridWidth-1)/2 -and $finalY -lt ($GridHeight-1)/2) {$RobotsInQuadrant[1]++}
		elseif ($finalX -lt ($GridWidth-1)/2 -and $finalY -gt ($GridHeight-1)/2) {$RobotsInQuadrant[2]++}
		elseif ($finalX -gt ($GridWidth-1)/2 -and $finalY -gt ($GridHeight-1)/2) {$RobotsInQuadrant[3]++}
	}
	$RobotsInQuadrant | ForEach-Object -Begin { $Result = 1} {$Result*=$_}
	if ($Result -le $MinSafety) {
		$MinSafety = $Result
		if ($RepeatCheck -ne ($RobotsInQuadrant -join ', ')) { $RepeatCheck = $RobotsInQuadrant -join ', '; $MinMoveCount = $MoveCount } else { Write-Host "Reached the safest place again on MoveCount $MoveCount. First time was at MoveCount $MinMoveCount"; break }
	}
	# Write-Host "MoveCount is $MoveCount. MinSafety is $MinSafety which was reached at $MinMoveCount"
	$MoveCount++
}

# Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host "Calculated answer: $MinMoveCount"
Write-Host "Correct answer: 7603"
Write-Host "To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('C:','/mnt/c').Replace('\','/'))"
Write-Host "To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('/mnt/c','C:').Replace('/','\'))"