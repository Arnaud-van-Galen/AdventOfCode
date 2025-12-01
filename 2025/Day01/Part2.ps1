Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
Set-StrictMode -Version Latest
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
# $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$Result = 0
$Position = 50

foreach ($DataLine in $Data) {
	if ($DataLine -match '^(?<Direction>[LR])(?<Clicks>\d+)') {
		$Direction = $Matches.Direction
		$Clicks = [int]$Matches.Clicks

		while ($Clicks -gt 0) {
			if ($Direction -eq 'L') {
				$Position--
			} elseif ($Direction -eq 'R') {
				$Position++
			}
			if ($Position % 100 -eq 0) { $Result++ }
			$Clicks--
		}
	}
}

Get-MyVariables
Write-Host 'Time for calculating:', $stopwatch.Elapsed.TotalSeconds
Write-Host 'Calculated answer:', $Result
Write-Host 'Correct answer: 6475 (6 for testdata)'
Write-Host 'To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('C:','/mnt/c').Replace('\','/')
Write-Host 'To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('/mnt/c','C:').Replace('/','\')