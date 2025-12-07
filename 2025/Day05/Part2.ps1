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
		$ToDoRanges.Push([PSCustomObject]@{Min = [int64]$Matches.Min; Max = [int64]$Matches.Max	})
	}
}
$Ranges += $ToDoRanges.Pop() # Start with one range to compare against

While ($ToDoRanges.Count -gt 0) {
	$ToDoRange = $ToDoRanges.Pop()
	# Write-Host "Processing ranges, $($ToDoRanges.Count) to go... Now processing range $($ToDoRange.Min)-$($ToDoRange.Max). $($Ranges.Count) ranges so far."
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

# Bonus, Combine all ranges that overlap into single ranges to reduce the number of ranges. I already went way overboard with the stack and overlapping logic above, but this is fun.
$RangesToCombine = $Ranges | Sort-Object Min
$Ranges = ,$RangesToCombine[0]
for ($RangeToCombine = 1; $RangeToCombine -lt $RangesToCombine.Count; $RangeToCombine++) {
	if ($RangesToCombine[$RangeToCombine].Min -eq $Ranges[-1].Max+1) {
		$Ranges[-1].Max = $RangesToCombine[$RangeToCombine].Max
	} else {
		$Ranges += $RangesToCombine[$RangeToCombine] | ConvertTo-Json | ConvertFrom-Json # Fake deepcopy to avoid reference issues that would modify the $rangesToCombine array
	}
}
Write-Host "Reduced ranges from $($RangesToCombine.Count) to $($Ranges.Count) by combining adjacent ranges. Display by typing `$RangesToCombine and `$Ranges"

foreach ($Range in $Ranges) {
	$Result += ($Range.Max - $Range.Min + 1)
}

Get-MyVariables
Write-Host 'Time for calculating:', $stopwatch.Elapsed.TotalSeconds
Write-Host 'Calculated answer:', $Result
Write-Host 'Correct answer: 350780324308385 (14 for testdata)'
Write-Host 'To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('C:','/mnt/c').Replace('\','/')
Write-Host 'To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('/mnt/c','C:').Replace('/','\')