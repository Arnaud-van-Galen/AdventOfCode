Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
Set-StrictMode -Version Latest
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -Raw -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -Raw -ErrorAction Stop

[int64]$Result = 0

foreach ($DataLine in $Data.Split(',')) {
	[int64]$Min, [int64]$Max = $DataLine.Split('-')
	for ($i = $Min; $i -le $Max; $i++) {
		$iString = $i.ToString()
		if ($iString.Length % 2 -eq 0) {
			if ($iString.Substring(0, $iString.Length/2) -eq $iString.Substring($iString.Length/2)) {
				$Result += $i
			# Write-Host "Repeating $iString. $Result"
			}
		}
	}
}

Get-MyVariables
Write-Host 'Time for calculating:', $stopwatch.Elapsed.TotalSeconds
Write-Host 'Calculated answer:', $Result
Write-Host 'Correct answer: 44854383294 (1227775554 for testdata)'
Write-Host 'To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('C:','/mnt/c').Replace('\','/')
Write-Host 'To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('/mnt/c','C:').Replace('/','\')