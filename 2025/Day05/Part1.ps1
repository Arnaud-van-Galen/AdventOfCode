Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
Set-StrictMode -Version Latest
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$Result = 0
$Ranges = @()

foreach ($DataLine in $Data) {
	if ($DataLine -match '(?<Min>\d*)-(?<Max>\d*)') {
		$Ranges += ([PSCustomObject]@{
			Min = [int64]$Matches.Min
			Max = [int64]$Matches.Max
		})
		continue
	}
	if ($DataLine -match '^(?<ID>\d+)$') {
		$ID = [int64]$Matches.ID
		$Spoiled = $true
		foreach ($Range in $Ranges) {
			if ($ID -ge $Range.Min -and $ID -le $Range.Max) {
				$Spoiled = $false
				break
			}
		}
		if (-not $Spoiled) {
			$Result++
		}
	}

}

Get-MyVariables
Write-Host 'Time for calculating:', $stopwatch.Elapsed.TotalSeconds
Write-Host 'Calculated answer:', $Result
Write-Host 'Correct answer: 664 (3 for testdata)'
Write-Host 'To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('C:','/mnt/c').Replace('\','/')
Write-Host 'To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('/mnt/c','C:').Replace('/','\')