Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$Rules = $Data.Where{$_.Contains('|')}
$UpdateData = $Data.Where{$_.Contains(',')}

foreach ($UpdateLine in $UpdateData) {
	$UpdateArray = $UpdateLine.Split(',')
	$Updates = @{}
	for ($i = 0; $i -lt $UpdateArray.Count; $i++) {
		$Updates[$UpdateArray[$i]] = $i
	}
	for ($i = 0; $i -lt $Rules.Count; $i++) {
		$RuleParts = $Rules[$i].Split('|')
		$RulePart0Position = $Updates[$RuleParts[0]] ; if ($null -eq $RulePart0Position) {continue} # Geen check nodig
		$RulePart1Position = $Updates[$RuleParts[1]] ; if ($null -eq $RulePart1Position) {continue} # Geen check nodig
		if ($RulePart1Position -lt $RulePart0Position) {break} # Rule broken
	}
	if ($i -eq $Rules.Count) {
		$Result += [int]$UpdateArray[($UpdateArray.count-1)/2]}
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 7024 (143 for testdata)