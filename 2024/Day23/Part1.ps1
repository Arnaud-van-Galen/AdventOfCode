Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
Set-StrictMode -Version Latest
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$Result = 0
$UniqueCombinations = [System.Collections.Generic.HashSet[string]]::new()
$ComputerNames = [regex]::Matches($Data -join '', '[a-z]{2}').value | Sort-Object -Unique
$ComputerNamesT = $ComputerNames.Where{$_.StartsWith('t')}
foreach ($ComputerT in $ComputerNamesT) {
	# $ComputerT=$ComputerNamesT[0]
	$Computers2 = $Data.Where{$_.Contains($ComputerT)}.Replace('-','').Replace($ComputerT,'')
	foreach ($Computer2 in $Computers2) {
		$Computers3 = $Data.Where{$_.Contains($Computer2)}.Replace('-','').Replace($Computer2,'').where{$_ -ne $ComputerT}
		foreach ($Computer3 in $Computers3) {
			if ($Data.Contains("$ComputerT-$Computer3") -or $Data.Contains("$Computer3-$ComputerT")) {
				$UniqueCombinations.Add((($ComputerT, $computer2, $Computer3) | Sort-Object) -join ',') | Out-Null
			}
		}
	}
}

# Get-MyVariables
Write-Host 'Time for calculating:', $stopwatch.Elapsed.TotalSeconds
Write-Host 'Calculated answer:', $UniqueCombinations.Count
Write-Host 'Correct answer: ??? (7 for testdata)'
Write-Host 'To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('C:','/mnt/c').Replace('\','/')
Write-Host 'To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('/mnt/c','C:').Replace('/','\')