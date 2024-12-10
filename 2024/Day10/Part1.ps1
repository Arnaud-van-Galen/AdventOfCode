Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$TrailHeads = [regex]::Matches($Data -join '', '0').Index
$Directions = @(@(-1,0), @(0,1), @(1,0), @(0,-1))
$GridHeight = $Data.Length
$GridWidth = $Data[0].Length
$Trails = @{}

for ($i = 0; $i -lt $TrailHeads.Count; $i++) {
	$Stack = [System.Collections.Stack]::new()
	$Stack.Push(@($TrailHeads[$i],$TrailHeads[$i])) # Begin, Head
	while ($Stack.Count -gt 0) {
		$Trail = $Stack.Pop()
		$TrailHead = [System.Math]::DivRem($Trail[1], $GridWidth)
		$Y, $X = $TrailHead.Item1, $TrailHead.Item2
		$Height = $Data[$Y][$X]-48
		foreach ($Direction in $Directions) {
			$NextY = $Y + $Direction[0]
			$NextX = $X + $Direction[1]
			if ($NextY -lt 0 -or $NextY -ge $GridHeight -or $NextX -lt 0 -or $NextX -ge $GridWidth) {continue} # Next Direction not on Map
			$NextHeight = $Data[$NextY][$NextX]-48
			if ($NextHeight -ne $Height+1) {continue} # Not a gradual slope
			if ($NextHeight -eq 9) {
				$Trails["$($Trail[0]),$($NextY*$GridWidth+$NextX)"]++
			} else {
				$Stack.Push(@($Trail[0],($NextY*$GridWidth+$NextX)))
			}
		}
	}
}

# Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host "Calculated answer: $($Trails.Count)"
Write-Host "Correct answer: 688 (36 for testdata)"
Write-Host "To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('C:','/mnt/c').Replace('\','/'))"
Write-Host "To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('/mnt/c','C:').Replace('/','\'))"