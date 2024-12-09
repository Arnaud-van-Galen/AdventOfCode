Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$BlockLayoutPos = 0
$FileBlocks = [ordered] @{}
$EmptyBlocks = [ordered] @{}
[Int64] $Result = 0

for ($i = 0; $i -lt $Data.Length; $i++) {
	$PosValue = $Data[$i]-48 #ASCII-value manipulation, much faster than # [int]$Data.Substring($i,1)
	if ($i % 2 -eq 0) {
		$FileBlocks.Add($BlockLayoutPos, $PosValue)
	} else {
		if ($PosValue -gt 0) {
			$emptyBlocks.Add($BlockLayoutPos, $PosValue)
		}
	}
	$BlockLayoutPos += $PosValue
}

$BlockLayout = @($null) * $BlockLayoutPos
while ($FileBlocks.Count -gt 0) {
	$FileValue = $FileBlocks.Count-1
	$FileStart = $FileBlocks.Keys[$FileValue]
	$FileLength = $FileBlocks.Values[$FileValue]
	$EmptyBlockIndex = 0
	$HasMoved = $false
	while (!$HasMoved -and $EmptyBlockIndex -le $EmptyBlocks.Count -and $EmptyBlocks.Keys[$EmptyBlockIndex] -lt $FileStart) {
		$EmptyBlockStart = $EmptyBlocks.Keys[$EmptyBlockIndex]
		$EmptyBlockLength = $EmptyBlocks.Values[$EmptyBlockIndex]
		if ($FileLength -le $EmptyBlockLength) {
			for ($i = $EmptyBlockStart; $i -lt $EmptyBlockStart+$FileLength; $i++) {
				$BlockLayout[$i] = $FileValue
			}
			$EmptyBlocks.RemoveAt($EmptyBlockIndex)
			if ($FileLength -ne $EmptyBlockLength) {
				$EmptyBlocks.Insert($EmptyBlockIndex, $EmptyBlockStart + $FileLength, $EmptyBlockLength - $FileLength)
			}
			$HasMoved = $true
		}
		$EmptyBlockIndex++
	}
	if (!$HasMoved) {
		for ($i = $FileStart; $i -lt $FileStart+$FileLength; $i++) {
			$BlockLayout[$i] = $FileValue
		}
	}
	$FileBlocks.RemoveAt($FileBlocks.Count-1)
	# ((0..($blocklayout.count-1)).foreach{$blocklayout[$_] ?? "."} -join '')
}

for ($i = 0; $i -lt $BlockLayout.Length; $i++) {
	if ($null -eq $BlockLayout[$i]) {continue}
	$Result+= $i*$BlockLayout[$i]
}

# Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 6307279963620 (2858 for testdata)