Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0
$MovesY = @(-1, 0, 1, 0)
$MovesX = @(0, 1, 0, -1)
$MoveIndex = 0
$PlannedRoute = @{}

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
$DataChars = $Data -join ''

$GridWidth = $Data[0].Length
$StartPosition = [System.Math]::DivRem($DataChars.IndexOf('^'), $GridWidth)
$GuardY = $StartPosition.Item1
$GuardX = $StartPosition.Item2

while ($GuardY -ge 0 -and $GuardY -lt $GridWidth -and $GuardX -ge 0 -and $GuardX -lt $GridWidth) {
	$PlannedRoute[$GuardY*$GridWidth+$GuardX]++
	do {
		$NextY = $GuardY + $MovesY[$MoveIndex % $MovesY.Count]
		$NextX = $GuardX + $MovesX[$MoveIndex % $MovesX.Count]
		if (($NextY -ge 0 -and $NextY -lt $GridWidth -and $NextX -ge 0 -and $NextX -lt $GridWidth) -and $Data[$NextY][$NextX] -eq '#') {$MoveIndex++}
	} until (!($NextY -ge 0 -and $NextY -lt $GridWidth -and $NextX -ge 0 -and $NextX -lt $GridWidth) -or $Data[$NextY][$NextX] -ne '#')
	$GuardY = $NextY
	$GuardX = $NextX
}
$Result = $PlannedRoute.Count

# Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 4778 (41 for testdata)