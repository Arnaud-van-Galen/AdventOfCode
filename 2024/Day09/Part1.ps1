Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$BlockLayout = @($null) * 10 * $Data.Length # MaxSize
$FilledBlocks = @($null) * 10 * $Data.Length # MaxSize
$EmptyBlocks = @($null) * 10 * $Data.Length # MaxSize, probably only half needed
$BlockLayoutPos = 0
$FilledBlocksPos = 0
$EmptyBlocksPos = 0
[Int64] $Result = 0

for ($i = 0; $i -lt $Data.Length; $i++) {
	$PosValue = $Data[$i]-48 #ASCII-value manipulation, much faster than # [int]$Data.Substring($i,1)
	for ($j = 0; $j -lt $PosValue; $j++) {
		if ($i % 2 -eq 0) {
			$BlockLayout[$BlockLayoutPos+$j]=$i/2
			$FilledBlocks[$FilledBlocksPos]=$BlockLayoutPos+$j
			$FilledBlocksPos++
		} else {
			$EmptyBlocks[$EmptyBlocksPos]=$BlockLayoutPos+$j
			$EmptyBlocksPos++
		}
	}
	$BlockLayoutPos = $BlockLayoutPos+$j
}

for ($i = 0; $i -lt $EmptyBlocksPos; $i++) {
	$EmptyPos, $FilledPos = $EmptyBlocks[$i], $FilledBlocks[$FilledBlocksPos-1-$i]
	if ($EmptyPos -ge $FilledPos) {continue}
	$BlockLayout[$EmptyBlocks[$i]]=$BlockLayout[$FilledBlocks[$FilledBlocksPos-1-$i]]
	$BlockLayout[$FilledBlocks[$FilledBlocksPos-1-$i]] = $null
	# if ($i % 100 -eq 0) {((0..($blocklayout.count-1)).foreach{$blocklayout[$_] ?? "."} -join '').trimend('.');[System.Console]::Clear()}
}
for ($i = 0; $i -lt $BlockLayout.Count; $i++) {
	if ($null -eq $BlockLayout[$i]) {continue}
	$Result += $i*$BlockLayout[$i]
}

Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 6291146824486 (1928 for testdata)