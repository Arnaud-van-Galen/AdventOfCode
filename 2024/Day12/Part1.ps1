Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$Data = Get-Content -Path $PSScriptRoot\DataDemo1.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\DataDemo2.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\DataDemo3.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

[Int64] $Result = 0
# $Types = [regex]::Matches($Data -join '','.') | Group-Object -CaseSensitive # First Draft idea

$GridHeight = $Data.Length
$GridWidth = $Data[0].Length
$Analyzed = New-Object -TypeName 'Object[]' -ArgumentList ($GridHeight*$GridWidth)
$Directions = @(@(-1,0), @(0,1), @(1,0), @(0,-1))

for ($AnalysisStart = 0; $AnalysisStart -lt $Analyzed.Count; $AnalysisStart++) {
	if ($null -eq $Analyzed[$AnalysisStart]) { # First not analyzed
		$RegionSearcher = [System.Collections.Stack]::new()
		$RegionSearcher.Push($AnalysisStart) # Start a new region called 0 (or 5 for the next)
		while ($RegionSearcher.Count -gt 0) {
			$RegionIndex = $RegionSearcher.Pop()
			$Region = [System.Math]::DivRem($RegionIndex, $GridWidth)
			$Y, $X = $Region.Item1, $Region.Item2
			$FenceCount = 0
			foreach ($Direction in $Directions) {
				$NextY = $Y + $Direction[0]
				$NextX = $X + $Direction[1]
				$NextIndex = $NextY * $GridWidth + $NextX
				if ($NextY -lt 0 -or $NextY -ge $GridHeight -or $NextX -lt 0 -or $NextX -ge $GridWidth) {
					$FenceCount++ # Next Direction is not on Map
				} else {
					if ($Data[$Y][$X] -ne $Data[$NextY][$NextX]) {
						$FenceCount++ # Next Direction is on Map but not the same type of Region
					} else {
						if ($null -eq $Analyzed[$NextIndex]) {
							if (!$RegionSearcher.Contains($NextIndex)) {
								$RegionSearcher.Push($NextIndex) # Next Direction is on Map, same type of Region, not analysed yet and not scheduled to be analyzed
							}
						}
					}
				}
			}
			$Analyzed[$RegionIndex] = @{Group=$AnalysisStart;Fences=$FenceCount}
			""
		}
		$Measurements = $Analyzed.Where{$null -ne $_ -and $_['Group'] -eq $AnalysisStart}.Fences | Measure-Object -Sum
		$Result += $Measurements.Count * $Measurements.Sum
	}
}

Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host "Calculated answer: $Result"
Write-Host "Correct answer: 1450816 (140 for testdata1, 772 for testdata2, 1930 for testdata3)"
Write-Host "To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('C:','/mnt/c').Replace('\','/'))"
Write-Host "To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('/mnt/c','C:').Replace('/','\'))"