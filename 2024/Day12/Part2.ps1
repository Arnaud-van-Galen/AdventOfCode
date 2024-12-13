Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$Data = Get-Content -Path $PSScriptRoot\DataDemoArnaud.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\DataDemo1.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\DataDemo2.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\DataDemo4.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\DataDemo5.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\DataDemo3.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

[Int64] $Result = 0
# $Types = [regex]::Matches($Data -join '','.') | Group-Object -CaseSensitive # First Draft idea

$GridHeight = $Data.Length
$GridWidth = $Data[0].Length
$Analyzed = New-Object -TypeName 'Object[]' -ArgumentList ($GridHeight * $GridWidth)
# $FencesVertical = New-Object -TypeName 'Object[]' -ArgumentList ($GridHeight * ($GridWidth + 1))
# $FencesHorizontal = New-Object -TypeName 'Object[]' -ArgumentList(($GridHeight + 1) * $GridWidth)
$Directions = @(@(-1,0), @(0,1), @(1,0), @(0,-1))

for ($AnalysisStart = 0; $AnalysisStart -lt $Analyzed.Count; $AnalysisStart++) {
	if ($null -eq $Analyzed[$AnalysisStart]) { # First not analyzed
		$RegionSearcher = [System.Collections.Stack]::new()
		$RegionSearcher.Push($AnalysisStart) # Start a new region called 0 (or 5 for the next)
		# $FencesVertical.Clear()
		# $FencesHorizontal.Clear()
		$FencesAbove = @()
		$FencesBelow = @()
		$FencesLeft = @()
		$FencesRight = @()
		$RegionCount = 0
		while ($RegionSearcher.Count -gt 0) {
			$RegionCount++
			$RegionIndex = $RegionSearcher.Pop()
			$Region = [System.Math]::DivRem($RegionIndex, $GridWidth)
			$Y, $X = $Region.Item1, $Region.Item2
			foreach ($Direction in $Directions) {
				$NextY = $Y + $Direction[0]
				$NextX = $X + $Direction[1]
				$NextIndex = $NextY * $GridWidth + $NextX
				if ($NextY -lt 0 -or $NextY -ge $GridHeight -or $NextX -lt 0 -or $NextX -ge $GridWidth) { # Next Direction is not on Map
					if ($Direction[1] -eq 0) { # Direction Vertical, so add horizontal fence above or below
						if ($Direction[0] -eq -1) { $FencesAbove += $RegionIndex } else { $FencesBelow += $RegionIndex + $GridWidth	}
					} else { # Direction Horizontal, so add vertical fence left or right
						if ($Direction[1] -eq -1) { $FencesLeft += $X * $GridHeight + $Y } else {	$FencesRight += $X * $GridHeight + $Y + $GridHeight }
					}
				} else {
					if ($Data[$Y][$X] -ne $Data[$NextY][$NextX]) { # Next Direction is on Map but not the same type of Region
						if ($Direction[1] -eq 0) { # Direction Vertical, so add horizontal fence above or below
							if ($Direction[0] -eq -1) { $FencesAbove += $RegionIndex } else { $FencesBelow += $RegionIndex + $GridWidth	}
						} else { # Direction Horizontal, so add vertical fence left or right
							if ($Direction[1] -eq -1) { $FencesLeft += $X * $GridHeight + $Y } else {	$FencesRight += $X * $GridHeight + $Y + $GridHeight }
						}
					} else {
						if ($null -eq $Analyzed[$NextIndex]) {
							if (!$RegionSearcher.Contains($NextIndex)) {
								$RegionSearcher.Push($NextIndex) # Next Direction is on Map, same type of Region, not analysed yet and not scheduled to be analyzed
							}
						}
					}
				}
			}
			$Analyzed[$RegionIndex] = $AnalysisStart
			""
		}
		$FenceCount = 0
		# Sort the 4 fences
		$FencesAbove = $FencesAbove | Sort-Object
		$FencesRight = $FencesRight | Sort-Object
		$FencesBelow = $FencesBelow | Sort-Object
		$FencesLeft = $FencesLeft | Sort-Object
		for ($i = 0; $i -lt $FencesAbove.Count; $i++) { if ($FencesAbove[$i]+1 -ne $FencesAbove[$i+1] -or (($FencesAbove[$i]+1) % $GridWidth) -eq 0) { $FenceCount++ } }
		for ($i = 0; $i -lt $FencesRight.Count; $i++) {	if ($FencesRight[$i]+1 -ne $FencesRight[$i+1] -or (($FencesRight[$i]+1) % $GridHeight) -eq 0) { $FenceCount++ }	}
		for ($i = 0; $i -lt $FencesBelow.Count; $i++) { if ($FencesBelow[$i]+1 -ne $FencesBelow[$i+1] -or (($FencesBelow[$i]+1) % $GridWidth) -eq 0) { $FenceCount++ } }
		for ($i = 0; $i -lt $FencesLeft.Count; $i++) { if ($FencesLeft[$i]+1 -ne $FencesLeft[$i+1] -or (($FencesLeft[$i]+1) % $GridHeight) -eq 0) { $FenceCount++ } }
		$Result += $RegionCount * $FenceCount
	}
}

# Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host "Calculated answer: $Result"
Write-Host "Correct answer: 865662 (80 for testdata1, 436 for testdata2, 236 for testdata4, 368 for testdata4, 1206 for testdata3)"
Write-Host "To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('C:','/mnt/c').Replace('\','/'))"
Write-Host "To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('/mnt/c','C:').Replace('/','\'))"