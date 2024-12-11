Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = "0 1 10 99 999"
# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

[Int64] $Result = 0
$BlinkCount = 25

foreach ($Stone in $Data.Split(' ')) {
	$Stones = @($Stone)
	for ($i = 1; $i -le $BlinkCount; $i++) {
		$NewStones = [System.Collections.ArrayList]::new()
		for ($s = 0; $s -lt $Stones.Count; $s++) {
			if ($Stones[$s] -eq '0') {
				$NewStones += '1'
			} elseif ($Stones[$s].Length % 2 -eq 0) {
				$NewStones += ([int64]$Stones[$s].Substring(0, $Stones[$s].Length / 2)).ToString()
				$NewStones += ([int64]$Stones[$s].Substring($Stones[$s].Length / 2)).ToString()
			} else {
				$NewStones += ([int64]$Stones[$s] * 2024).ToString()
			}
		}
		$Stones = $NewStones
		# "After BlinkCount $i $Stone became $Stones"
	}
	$Result += $Stones.Count
}

Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host "Calculated answer: $Result"
Write-Host "Correct answer: 222461 (22 and 55312 for testdata with BlinkCount 6 and 25)"
Write-Host "To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('C:','/mnt/c').Replace('\','/'))"
Write-Host "To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('/mnt/c','C:').Replace('/','\'))"