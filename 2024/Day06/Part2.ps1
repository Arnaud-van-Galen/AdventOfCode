Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0
$MovesY = @(-1, 0, 1, 0)
$MovesX = @(0, 1, 0, -1)
$MoveIndex = 0
$PlannedRouteDic = [ordered]@{}

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
$DataChars = $Data -join ''

$GridWidth = $Data[0].Length
$StartPosition = [System.Math]::DivRem($DataChars.IndexOf('^'), $GridWidth)
$GuardY = $StartPosition.Item1
$GuardX = $StartPosition.Item2

while ($GuardY -ge 0 -and $GuardY -lt $GridWidth -and $GuardX -ge 0 -and $GuardX -lt $GridWidth) {
	$PlannedRouteDic[@($GuardY, $GuardX, $MoveIndex)] = $true
	do {
		$NextY = $GuardY + $MovesY[$MoveIndex]
		$NextX = $GuardX + $MovesX[$MoveIndex]
		if (($NextY -ge 0 -and $NextY -lt $GridWidth -and $NextX -ge 0 -and $NextX -lt $GridWidth) -and $DataChars[$NextY*$GridWidth+$NextX] -eq '#') {$MoveIndex = ($MoveIndex+1)%$MovesY.Count}
	} until (!($NextY -ge 0 -and $NextY -lt $GridWidth -and $NextX -ge 0 -and $NextX -lt $GridWidth) -or $DataChars[$NextY*$GridWidth+$NextX] -ne '#')
	$GuardY = $NextY
	$GuardX = $NextX
}

$SuccesfulBlocks = @{}
$ForbiddenBlocks = @{}
$DataChars = ($Data -join '').ToCharArray()
for ($i = 0; $i -lt $PlannedRouteDic.Count; $i++) {
	$GuardY, $GuardX, $MoveIndex = $PlannedRouteDic.Keys[$i]
	$ForbiddenBlocks["$GuardY,$GuardX"] = $true
	if ($i+1 -lt $PlannedRouteDic.Count) { # Put an extra block on the next point in the route if the guard hasn't visited there yet
		$BlockY, $BlockX = $PlannedRouteDic.Keys[$i+1][0,1]
		if ($ForbiddenBlocks.ContainsKey("$BlockY,$BlockX")) {continue}
		$DataChars[$BlockY*$GridWidth+$BlockX] = '#'
	}
	$altRoute = @{}
	while ($GuardY -ge 0 -and $GuardY -lt $GridWidth -and $GuardX -ge 0 -and $GuardX -lt $GridWidth) {
		$key = "$GuardY,$GuardX,$MoveIndex"
		if ($altRoute.ContainsKey($key)) {
			$SuccesfulBlocks["$BlockY,$BlockX"] = $true
			# Write-Host "altroute with block at $BlockY, $BlockX works. $($SuccesfulBlocks.Count) total unique blocks"
			break
		}
		$altRoute[$key] = $true
		do {
			$NextY = $GuardY + $MovesY[$MoveIndex]
			$NextX = $GuardX + $MovesX[$MoveIndex]
			if (($NextY -ge 0 -and $NextY -lt $GridWidth -and $NextX -ge 0 -and $NextX -lt $GridWidth) -and $DataChars[$NextY*$GridWidth+$NextX] -eq '#') {$MoveIndex = ($MoveIndex+1)%$MovesY.Count}
		} until (!($NextY -ge 0 -and $NextY -lt $GridWidth -and $NextX -ge 0 -and $NextX -lt $GridWidth) -or $DataChars[$NextY*$GridWidth+$NextX] -ne '#')
		$GuardY = $NextY
		$GuardX = $NextX
	}
	$DataChars[$BlockY*$GridWidth+$BlockX] = '.' # Remove the extra block
}
$Result = $SuccesfulBlocks.Count

# Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 1618 (6 for testdata)