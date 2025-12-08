Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
Set-StrictMode -Version Latest
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop; $ConnectionsToMake = 10
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop; $ConnectionsToMake = 1000

$Result = 1

$Boxes = [PSCustomObject[]]::new($Data.Count)
$Distances = [PSCustomObject[]]::new(($Data.Count-1)*$Data.Count/2)

for ($i = 0; $i -lt $Data.Count; $i++) {
	[int[]]$Values = $Data[$i].Split(',')
	$Boxes[$i] = [PSCustomObject]@{ X=$Values[0]; Y=$Values[1] ; Z=$Values[2] } 
}
Write-Host "Loaded $($Boxes.Count) boxes."

$d=0
for ($i = 0; $i -lt $Boxes.Count-1; $i++) {
	for ($j = $i+1; $j -lt $Boxes.Count; $j++) {
		$dx = $Boxes[$i].X - $Boxes[$j].X
		$dy = $Boxes[$i].Y - $Boxes[$j].Y
		$dz = $Boxes[$i].Z - $Boxes[$j].Z
		$Distances[$d] = [PSCustomObject]@{ Box1=$i; Box2=$j; Distance=[math]::Sqrt($dx*$dx + $dy*$dy + $dz*$dz) }
		$d++
	}
}
$Distances = $Distances | Sort-Object Distance
Write-host "Calculated $($Distances.Count) distances."

$Circuits = [System.Collections.Generic.List[int[]]]::new()
for ($i = 0; $i -lt $ConnectionsToMake; $i++) {
	$Box1 = $Distances[$i].Box1
	$Box2 = $Distances[$i].Box2
	$Circuit1, $Circuit2 = $null
	for ($c = 0; $c -lt $Circuits.Count; $c++) {
		$Circuit = $Circuits[$c]
		if ($Circuit -contains $Box1) {$Circuit1 = $c}
		if ($Circuit -contains $Box2) {$Circuit2 = $c}
	}
	if ($null -ne $Circuit1 -and $null -ne $Circuit2) {
		if ($Circuit1 -ne $Circuit2) {
			$Circuits.Add(($Circuits[$Circuit1] += $Circuits[$Circuit2]))
			($Circuit1, $Circuit2) | Sort-Object -Descending | ForEach-Object {$Circuits.RemoveAt($_)} # Remove higher index first to prevent "race condition"
		}
	} elseif ($null -ne $Circuit1) {
		$Circuits[$Circuit1] += $Box2
	} elseif ($null -ne $Circuit2) {
		$Circuits[$Circuit2] += $Box1
	} else {
		$Circuits.Add(($Box1,$box2))
	}
	# Write-Host "After processing distance $i between box $Box1 and box $Box2, we have $($Circuits.Count) circuits."
}
$Circuits | ForEach-Object {$_.count} | Sort-Object -Descending -top 3 | forEach-Object {$Result*=$_}

Get-MyVariables
Write-Host 'Time for calculating:', $stopwatch.Elapsed.TotalSeconds
Write-Host 'Calculated answer:', $Result
Write-Host 'Correct answer: 66912 (40 for testdata)'
Write-Host 'To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('C:','/mnt/c').Replace('\','/')
Write-Host 'To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('/mnt/c','C:').Replace('/','\')