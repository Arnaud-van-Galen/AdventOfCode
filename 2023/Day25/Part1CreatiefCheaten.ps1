Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int[]] $Results = @()
[int] $Result = 0

# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
$UniqueComponentCount = ([Regex]::Matches($Data, '[a-z]{3}').Value | Select-Object -Unique).Count
@(1..([Math]::Floor($UniqueComponentCount/2))).ForEach{$Results += $_*($UniqueComponentCount-$_)}

while ($Result -eq 0 -and $Results.Count -gt 1) {
	$ResultToTry = $Results[[Math]::Floor($Results.Count/2)]
	$Answer = Read-Host -Prompt "$($Results.Count) possible answers left. When you post $ResultToTry as the solution, does it tell you the result is (C)orrect, too (H)igh or too (L)ow?"
	if ($Answer -eq 'C') {
		$Result = $ResultToTry
	} elseif ($Answer -eq 'H') {
		$Results = $Results.Where{$_ -lt $ResultToTry}
	} elseif ($Answer -eq 'L') {
		$Results = $Results.Where{$_ -gt $ResultToTry}
	} else {
		Write-Error "Only type C, H or L. Try again"
	}
}
if ($Results.Count -eq 1) {$Result = $Results[0]}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 600225 (54 for testdata)