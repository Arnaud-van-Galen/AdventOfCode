Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
Set-StrictMode -Version Latest
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

[int64] $Result = 0
$DigitsFound = ,0*12

function Find-Max {param ($DigitsToScan)
	$Max, $Position = 0
	for ($CurrentPosition = 0; $CurrentPosition -lt $DigitsToScan.Length; $CurrentPosition++) {
		$Digit = [int] $DigitsToScan[$CurrentPosition].ToString()
		if ($Digit -gt $Max) {
			$Max = $Digit
			$Position = $CurrentPosition
		}
	}
	return [PSCustomObject]@{Max = $Max; Position = $Position}
}

foreach ($DataLine in $Data) {
	$Position = 0
	for ($i = 0; $i -lt $DigitsFound.Count; $i++) {
		$FoundMax = Find-Max -DigitsToScan $DataLine.Substring($position, $DataLine.Length - $position - $DigitsFound.Count + $i +1)
		$DigitsFound[$i] = $FoundMax.Max
		$Position += $FoundMax.Position + 1
	}
	$DigitsFound -join ''
	$Result += $DigitsFound -join ''
}

Get-MyVariables
Write-Host 'Time for calculating:', $stopwatch.Elapsed.TotalSeconds
Write-Host 'Calculated answer:', $Result
Write-Host 'Correct answer: 173532612395671 (3121910778619 for testdata)'
Write-Host 'To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('C:','/mnt/c').Replace('\','/')
Write-Host 'To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('/mnt/c','C:').Replace('/','\')