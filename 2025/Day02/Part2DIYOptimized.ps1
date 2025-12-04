Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
Set-StrictMode -Version Latest
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -Raw -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -Raw -ErrorAction Stop

[int64]$Result = 0
$divisorCache = @{}

foreach ($DataLine in $Data.Split(',')) {
	[int64]$Min, [int64]$Max = $DataLine.Split('-')
	for ($i = $Min; $i -le $Max; $i++) {
		$iString = $i.ToString()
		$Number = $iString.Length
		if ($divisorCache.ContainsKey($Number)) {
			$divisors =  $divisorCache[$Number]
		} else {
			$divisors = 1..$Number | Where-Object { $Number % $_ -eq 0 } | ForEach-Object { [PSCustomObject]@{
        DivisorLength = $_
        DivisorTimes  = $Number / $_
    	}}
			$divisorCache[$Number] = $divisors
		}
		for ($divisor = 0; $divisor -lt $divisors.Count-1; $divisor++) {
			if ($iString.Substring(0, $divisors[$divisor].DivisorLength)*$divisors[$divisor].DivisorTimes-eq $iString) {
				$Result += $i
				# Write-Host "Repeating $iString. $Result"
				break
			}
		}
	}
}

Get-MyVariables
Write-Host 'Time for calculating:', $stopwatch.Elapsed.TotalSeconds
Write-Host 'Calculated answer:', $Result
Write-Host 'Correct answer: 55647141923 (4174379265 for testdata)'
Write-Host 'To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('C:','/mnt/c').Replace('\','/')
Write-Host 'To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('/mnt/c','C:').Replace('/','\')