Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
Set-StrictMode -Version Latest
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$Result = 0
$ToDoRanges = [System.Collections.Stack]::new()
$Ranges = @()

foreach ($DataLine in $Data) {
	if ($DataLine -match '(?<Min>\d*)-(?<Max>\d*)') {
		# $Ranges += [PSCustomObject]@{Min = [int64]$Matches.Min; Max = [int64]$Matches.Max	}
		$ToDoRanges.Push([PSCustomObject]@{Min = [int64]$Matches.Min; Max = [int64]$Matches.Max	})
	}
}
# $Ranges | Sort-Object { $_.Max - $_.Min } | ForEach-Object { $ToDoRanges.Push($_) } # Make sure the largest ranges are processed first. I think a queue where I put largest first and add leftovers to the end would be better
# $Ranges = @()
$Ranges += $ToDoRanges.Pop() # Start with one range to compare against

While ($ToDoRanges.Count -gt 0) {
	$ToDoRange = $ToDoRanges.Pop()
	Write-Host "Processing ranges, $($ToDoRanges.Count) to go... Now processing range $($ToDoRange.Min)-$($ToDoRange.Max). $($Ranges.Count) ranges so far."
	$HasOverlap = $false
	foreach ($Range in $Ranges) {
		# Write-Host "Comparing to range $($Range.Min)-$($Range.Max)..."
		if ($ToDoRange.Max -lt $Range.Min -or $ToDoRange.Min -gt $Range.Max) {
			# No overlap. Range=5-25, ToDoRange=0-4 of ToDoRange=26-40
		} elseif ($ToDoRange.Max -le $Range.Max -and $ToDoRange.Min -ge $Range.Min) {
			# Full overlap of ToDoRange by Range. Range=5-25, ToDoRange=5-25 or ToDoRange=5-24 or ToDoRange=6-25
			$HasOverlap = $true; continue
		} elseif ($ToDoRange.Max -gt $Range.Max -and $ToDoRange.Min -lt $Range.Min) {
			# Partial overlap but remainder on both sides. Range=5-25, ToDoRange=0-30
			$ToDoRanges.Push([PSCustomObject]@{Min = $ToDoRange.Min; Max = $Range.Min - 1})
			$ToDoRanges.Push([PSCustomObject]@{Min = $Range.Max + 1; Max = $ToDoRange.Max})
			$HasOverlap = $true; continue
		} elseif ($ToDoRange.Max -le $Range.Max) {
			# Partial overlap but remainder on left. Range=5-25, ToDoRange=0-24
			$ToDoRanges.Push([PSCustomObject]@{Min = $ToDoRange.Min; Max = $Range.Min - 1})
			$HasOverlap = $true; continue
		} else {
			# Partial overlap but remainder on right Range=5-25, ToDoRange=6-30
			$ToDoRanges.Push([PSCustomObject]@{Min = $Range.Max + 1; Max = $ToDoRange.Max})
			$HasOverlap = $true; continue
		}
	}
	if (-not $HasOverlap) {$Ranges += $ToDoRange}
}
foreach ($Range in $Ranges) {
	$Result += ($Range.Max - $Range.Min + 1) # Add full range size to result, will subtract overlaps later
}

Get-MyVariables
Write-Host 'Time for calculating:', $stopwatch.Elapsed.TotalSeconds
Write-Host 'Calculated answer:', $Result
Write-Host 'Correct answer: 350780324308385 (14 for testdata)'
Write-Host 'To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('C:','/mnt/c').Replace('\','/')
Write-Host 'To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('/mnt/c','C:').Replace('/','\')