Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

[Int64] $Result = 0
$Numbers = [regex]::Matches($Data -join '', '\d+')
$MaxAttempts = 100

for ($i = 0; $i -lt $Numbers.Count; $i+=6) { # Numbers are grouped per 6
	$aX = [int]$Numbers[$i + 0].Value
	$aY = [int]$Numbers[$i + 1].Value
	$bX = [int]$Numbers[$i + 2].Value
	$bY = [int]$Numbers[$i + 3].Value
	$pX = [int]$Numbers[$i + 4].Value
	$pY = [int]$Numbers[$i + 5].Value
	$UnreachableAmount = $MaxAttempts*3 + $MaxAttempts + 1
	$MinMoneySpent = $UnreachableAmount
	for ($a = 0; $a -lt $MaxAttempts; $a++) {
		$xPos = $a * $aX ; if ($xPos -gt $pX) {continue} # moved to far right already
		$yPos = $a * $aY ; if ($yPos -gt $pY) {continue} # moved to far up already
		$aMoneySpent = $a * 3 ; if ($aMoneySpent -gt $MinMoneySpent) {continue} # spent to much money on button A already
		$bNeeded = ($pX - $xPos) / $bx ; if ($bNeeded -ne [int]$bNeeded) {continue} # cannot reach the right exactly by using button B
		if ($by * $bNeeded + $yPos -eq $pY) { # reached the prize
			$MoneySpent = $a*3 + $bNeeded
			# "$i : Reached prize $Py, $Px with $a $aX,$aY and $bNeeded $bX,$bY costing $MoneySpent"
			if ($MoneySpent -lt $MinMoneySpent) {$MinMoneySpent = $MoneySpent}
		}
	}
	if ($MinMoneySpent -ne $UnreachableAmount) { $Result+=$MinMoneySpent}
}

# Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host "Calculated answer: $Result"
Write-Host "Correct answer: 29877 (480 for testdata)"
Write-Host "To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('C:','/mnt/c').Replace('\','/'))"
Write-Host "To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('/mnt/c','C:').Replace('/','\'))"