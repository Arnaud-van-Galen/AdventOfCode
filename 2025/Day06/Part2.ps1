Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
Set-StrictMode -Version Latest
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$Result = 0

$DataColumns = [array]::CreateInstance([string], $Data[0].Length+1)
for ($X = 0; $X -lt $Data[0].Length; $X++) {
	for ($Y = 0; $Y -lt $Data.Count; $Y++) {
		$DataColumns[$X] += $Data[$Y][$X]
	}
}
$DataColumns[-1] = ''

$SumResult = 0
foreach ($DataLine in $DataColumns.Trim()) {
	if ($DataLine.EndsWith('+')) {
		$SumResult = [int]$DataLine.Split('+')[0]
		$Operator = '+'
	} elseif ($DataLine.EndsWith('*')) {
		$SumResult = [int]$DataLine.Split('*')[0]
		$Operator = '*'
	} elseif ($DataLine.Length -gt 0) {
		if ($Operator -eq '+') { $SumResult += $DataLine } else { $SumResult *= $DataLine }
	} else {
		$Result += $SumResult
	}
}

Get-MyVariables
Write-Host 'Time for calculating:', $stopwatch.Elapsed.TotalSeconds
Write-Host 'Calculated answer:', $Result
Write-Host 'Correct answer: 9194682052782 (3263827 for testdata)'
Write-Host 'To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('C:','/mnt/c').Replace('\','/')
Write-Host 'To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('/mnt/c','C:').Replace('/','\')