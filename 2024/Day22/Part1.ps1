Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
Set-StrictMode -Version Latest
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# [int[]]$Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[int[]]$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$Result = 0

foreach ($SecretNumber in $Data) {
	for ($i = 0; $i -lt 2000; $i++) {
		$PseudoRandom = $SecretNumber * 64 # multiplying the secret number by 64
		$SecretNumber = $PseudoRandom -bxor $SecretNumber # mix this result into the secret number
		$SecretNumber = $SecretNumber % 16777216 # Prune the secret number
		
		$PseudoRandom = [int]::CreateTruncating($SecretNumber / 32) # dividing the secret number by 32
		$SecretNumber = $PseudoRandom -bxor $SecretNumber # mix this result into the secret number
		$SecretNumber = $SecretNumber % 16777216 # Prune the secret number
		
		$PseudoRandom = $SecretNumber * 2048 # multiplying the secret number by 2048
		$SecretNumber = $PseudoRandom -bxor $SecretNumber # mix this result into the secret number
		$SecretNumber = $SecretNumber % 16777216 # Prune the secret number
		# "$i : secretnumber became $SecretNumber"
	}
	# $SecretNumber
	$Result += $SecretNumber
}

# Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host "Calculated answer: $Result"
Write-Host "Correct answer: 14273043166 (37327623 for testdata)"
Write-Host "To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('C:','/mnt/c').Replace('\','/'))"
Write-Host "To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('/mnt/c','C:').Replace('/','\'))"