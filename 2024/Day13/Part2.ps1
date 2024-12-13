Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

[Int64] $Result = 0
$Numbers = [regex]::Matches($Data -join '', '\d+')

for ($i = 0; $i -lt $Numbers.Count; $i+=6) { # Numbers are grouped per 6
	$aX = [Int64]$Numbers[$i + 0].Value
	$aY = [Int64]$Numbers[$i + 1].Value
	$bX = [Int64]$Numbers[$i + 2].Value
	$bY = [Int64]$Numbers[$i + 3].Value
	$pX = [Int64]$Numbers[$i + 4].Value + 10000000000000
	$pY = [Int64]$Numbers[$i + 5].Value + 10000000000000
	# $CrossAx = $aX*$aY
	$CrossBx = $bX*$aY
	$CrossPx = $pX*$aY
	# $CrossAy = $aY*$aX
	$CrossBy = $bY*$aX
	$CrossPy = $pY*$aX
	$bNeeded = ($CrossPx-$CrossPy) / ($CrossBx-$CrossBy) # 2 vergelijkingen met 2 variabelen, verwijder de eerste var ($CrossAx is $CrossAy)
	if ($bNeeded -ne [Int64]$bNeeded) {continue} # cannot reach the right exactly by using button B
	$a = ($pX-($bx*$bNeeded))/$aX
	if ($a -eq [Int64]$a ) {
		$MoneySpent = $a*3 + $bNeeded
		# "$i : Reached prize $Py, $Px with $a $aX,$aY and $bNeeded $bX,$bY costing $MoneySpent"
		$Result += $MoneySpent
	}
}

# Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host "Calculated answer: $Result"
Write-Host "Correct answer: 99423413811305 (875318608908 for testdata but AOC only mentions that only the 2nd and 4th can win (input 6 and 18))"
Write-Host "To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('C:','/mnt/c').Replace('\','/'))"
Write-Host "To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('/mnt/c','C:').Replace('/','\'))"