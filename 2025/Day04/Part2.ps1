Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
Set-StrictMode -Version Latest
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$Result = 0

$Directions = @(@(-1,-1), @(-1,0), @(-1,1), @(0,-1),@(0,1), @(1,-1), @(1,0), @(1,1))
$GridHeight = $Data.Length
$GridWidth = $Data[0].Length

do {
	$SomethingChanged = $false
	for ($Y = 0; $Y -lt $GridHeight; $Y++) {
		for ($X = 0; $X -lt $GridWidth; $X++) {
			if ($Data[$Y][$X] -ne '@') { continue } # Not a roll of paper
			$RollCount = 0
			foreach ($Direction in $Directions) {
				$TestY = $Y + $Direction[0]
				$TestX = $X + $Direction[1]
				if ($TestY -lt 0 -or $TestY -ge $GridHeight -or $TestX -lt 0 -or $TestX -ge $GridWidth) {continue} # Not in Grid
				if ($Data[$TestY][$TestX] -eq '@') {$RollCount++}
			}
			if ($RollCount -lt 4) {
				$Result++
				# Write-Host "Found a roll of paper at ($Y,$X) with only $RollCount adjacent empty spaces"
				$SomethingChanged = $true
				$Data[$Y] = $Data[$Y].Substring(0, $X) + "X" + $Data[$Y].Substring($X+1)
			}
		}
	}
} while ($SomethingChanged)

Get-MyVariables
Write-Host 'Time for calculating:', $stopwatch.Elapsed.TotalSeconds
Write-Host 'Calculated answer:', $Result
Write-Host 'Correct answer: 8890 (43 for testdata)'
Write-Host 'To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('C:','/mnt/c').Replace('\','/')
Write-Host 'To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('/mnt/c','C:').Replace('/','\')