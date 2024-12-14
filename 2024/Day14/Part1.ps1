Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

# $GridHeight, $GridWidth = (7,11)
$GridHeight, $GridWidth = (103,101)
$MoveCount = 100
$RobotsInQuadrant = @(0,0,0,0)
[Int64]$Result = 1

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
}
$RobotsInQuadrant.ForEach{$Result*=$_}

# Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host "Calculated answer: $Result"
Write-Host "Correct answer: 224438715 (12 for testdata)"
Write-Host "To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('C:','/mnt/c').Replace('\','/'))"
Write-Host "To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('/mnt/c','C:').Replace('/','\'))"