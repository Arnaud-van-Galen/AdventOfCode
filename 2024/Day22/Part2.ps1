Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
Set-StrictMode -Version Latest
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# [int[]]$Data = (1,2,3,2024)
[int[]]$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$Differences = [hashtable]::new($Data.Count*1997)
foreach ($SecretNumber in $Data) {
	$Ones = [byte[]]::new(2001) # 2000 + 1
	$Ones[0] = $SecretNumber % 10
	$LocalDifferences = [System.Collections.Generic.HashSet[string]]::new(1997) # 2000 + 1 - 4
	for ($i = 1; $i -le 2000; $i++) {
		$PseudoRandom = $SecretNumber * 64 # multiplying the secret number by 64
		$SecretNumber = $PseudoRandom -bxor $SecretNumber # mix this result into the secret number
		$SecretNumber = $SecretNumber % 16777216 # Prune the secret number
		
		$PseudoRandom = [int]::CreateTruncating($SecretNumber / 32) # dividing the secret number by 32
		$SecretNumber = $PseudoRandom -bxor $SecretNumber # mix this result into the secret number
		$SecretNumber = $SecretNumber % 16777216 # Prune the secret number
		
		$PseudoRandom = $SecretNumber * 2048 # multiplying the secret number by 2048
		$SecretNumber = $PseudoRandom -bxor $SecretNumber # mix this result into the secret number
		$SecretNumber = $SecretNumber % 16777216 # Prune the secret number

		$Ones[$i] = $SecretNumber % 10
		if ($i -ge 4) {
			$Key = "$($Ones[$i-3]-$Ones[$i-4]),$($Ones[$i-2]-$Ones[$i-3]),$($Ones[$i-1]-$Ones[$i-2]),$($Ones[$i]-$Ones[$i-1])"
			if ($LocalDifferences.Add($Key)) { $Differences[$Key] += ($SecretNumber % 10) }
		}
	}
}

# Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host "Calculated answer: $(($Differences.Values | Measure-Object -Maximum).Maximum)"
Write-Host "Correct answer: 1667 (23 for testdata)"
Write-Host "To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('C:','/mnt/c').Replace('\','/'))"
Write-Host "To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('/mnt/c','C:').Replace('/','\'))"