Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
Set-StrictMode -Version Latest
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$Result = 0

$SumParts = $Data.Split(' ',[System.StringSplitOptions]::RemoveEmptyEntries)
$SumCount = $SumParts.Count / $Data.Count
for ($Column = 0; $Column -lt $SumCount; $Column++) {
	$Operator = $SumParts[$SumParts.Count - $SumCount + $Column]
	$SumResult = if ($Operator -eq '+') {0} else {1}
	for ($Row = 0; $Row -lt $Data.Count-1; $Row++) {
		$Value = $SumParts[$Row * $SumCount + $Column]
		if ($Operator -eq '+') { $SumResult += $Value } else { $SumResult *= $Value }
	}
	$Result += $SumResult
}

Get-MyVariables
Write-Host 'Time for calculating:', $stopwatch.Elapsed.TotalSeconds
Write-Host 'Calculated answer:', $Result
Write-Host 'Correct answer: 6295830249262 (4277556 for testdata)'
Write-Host 'To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('C:','/mnt/c').Replace('\','/')
Write-Host 'To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('/mnt/c','C:').Replace('/','\')