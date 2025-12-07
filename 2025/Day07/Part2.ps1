Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
Set-StrictMode -Version Latest
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$Result = 0

$Tachyons = @{$Data[0].IndexOf('S') = 1}
foreach ($DataLine in $Data) {
	$Splitters = [regex]::Matches($DataLine, '\^') | ForEach-Object { $_.Index }
	# Write-Host "Line: $DataLine has splitters at: $Splitters and tachyons at: $($Tachyons.Keys). There are $($Tachyons.Count) tachyons in $(($Tachyons.Values | Measure-Object -Sum).Sum) ways"
	if ($Splitters) {
		$NewTachyons = @{}
		foreach ($Tachyon in $Tachyons.Keys) {
			if ($Tachyon -in $Splitters) {
				$NewTachyons[$Tachyon+1] += $Tachyons[$Tachyon]
				$NewTachyons[$Tachyon-1] += $Tachyons[$Tachyon]
			} else {
				$NewTachyons[$Tachyon] += $Tachyons[$Tachyon]
			}
		}
		$Tachyons = $NewTachyons
	}
}
$Result = ($Tachyons.Values | Measure-Object -Sum).Sum

Get-MyVariables
Write-Host 'Time for calculating:', $stopwatch.Elapsed.TotalSeconds
Write-Host 'Calculated answer:', $Result
Write-Host 'Correct answer: 7759107121385 (40 for testdata)'
Write-Host 'To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('C:','/mnt/c').Replace('\','/')
Write-Host 'To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('/mnt/c','C:').Replace('/','\')