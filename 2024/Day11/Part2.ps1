Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$BlinkCount = 75
$Stones = @{}
$Data.Split().ForEach{$Stones[$_]++}

for ($i = 1; $i -le $BlinkCount; $i++) {
	$NewStones = @{}
	foreach ($StoneGroup in $Stones.Keys) {
		if ($StoneGroup -eq '0') {
			$NewStones['1'] += $Stones[$StoneGroup]
		} elseif ($StoneGroup.Length % 2 -eq 0) {
			$NewStones[([int64]$StoneGroup.Substring(0, $StoneGroup.Length / 2)).ToString()] += $Stones[$StoneGroup]
			$NewStones[([int64]$StoneGroup.Substring($StoneGroup.Length / 2)).ToString()] += $Stones[$StoneGroup]
		} else {
			$NewStones[([int64]$StoneGroup * 2024).ToString()] += $Stones[$StoneGroup]
		}
	}
	$Stones = $NewStones
	# "After BlinkCount $i there are $($Stones.Count) different stones. $(($Stones.values | Measure-Object -Sum).Sum) stones in total"
}

Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host "Calculated answer: $(($Stones.values | Measure-Object -Sum).Sum)"
Write-Host "Correct answer: 264350935776416 (222461 with BlinkCount 25 like in Part1)"
Write-Host "To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('C:','/mnt/c').Replace('\','/'))"
Write-Host "To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('/mnt/c','C:').Replace('/','\'))"