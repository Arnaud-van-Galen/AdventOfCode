Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
Set-StrictMode -Version Latest
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$Result = 0

foreach ($DataLine in $Data) {
	$LeftPosition = 0
	$LeftMax = 0
	$DigitsToScan = $DataLine.Substring(0, $DataLine.Length - 1)
	for ($CurrentPosition = 0; $CurrentPosition -lt $DigitsToScan.Length; $CurrentPosition++) {
		$Digit = [int] $DigitsToScan[$CurrentPosition].ToString()
		if ($Digit -gt $LeftMax) {
			$LeftMax = $Digit
			$LeftPosition = $CurrentPosition
		}
	}
	$RightPosition = 0
	$RightMax = 0
	$DigitsToScan = $DataLine.Substring($LeftPosition + 1)
	for ($CurrentPosition = 0; $CurrentPosition -lt $DigitsToScan.Length; $CurrentPosition++) {
		$Digit = [int] $DigitsToScan[$CurrentPosition].ToString()
		if ($Digit -gt $RightMax) {
			$RightMax = $Digit
			$RightPosition = $CurrentPosition
		}
	}
	Write-Host "Leftmost highest digit in $DataLine is $LeftMax at position $LeftPosition. Rightmost is $rightMax at position $RightPosition."
	$Result += "" + $LeftMax + $RightMax
}

Get-MyVariables
Write-Host 'Time for calculating:', $stopwatch.Elapsed.TotalSeconds
Write-Host 'Calculated answer:', $Result
Write-Host 'Correct answer: 17535 (357 for testdata)'
Write-Host 'To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('C:','/mnt/c').Replace('\','/')
Write-Host 'To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('/mnt/c','C:').Replace('/','\')