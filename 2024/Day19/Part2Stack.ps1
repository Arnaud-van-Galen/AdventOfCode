Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
# $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

[Int64] $Result = 0
$ThanksForHelpingMeRememberGio = @{}

$Towels = $Data[0].Split(', ')
for ($i = 2; $i -lt $Data.Count; $i++) {
	# $Result += RecursivelyFind -Design $Data[$i]
	
	if ($ThanksForHelpingMeRememberGio.ContainsKey($Data[$i])) { return $ThanksForHelpingMeRememberGio[$Data[$i]] }
	$Count = 0
	$Stack = [System.Collections.Stack]::new()
	$Stack.Push(($Data[$i], $Count))
	while ($Stack.Count -gt 0) {
		$CurrentSubstring, $CurrentCount = $Stack.Pop()
		if ($CurrentSubstringtSubstring -eq "") {	$Count += 1 ; continue }
		foreach ($Towel in $Towels) {	if ($CurrentSubstringtSubstring.StartsWith($Towel)) { $Stack.Push(($CurrentSubstringrentSubstring.Substring($Towel.Length), $CurrentCount)) } }
	}
	$ThanksForHelpingMeRememberGio[$Design] = $Count  # Add to cache
	return $Count
}

# Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host "Calculated answer: $Result"
Write-Host "Correct answer: 636483903099279 (16 for testdata)"
Write-Host "To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('C:','/mnt/c').Replace('\','/'))"
Write-Host "To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('/mnt/c','C:').Replace('/','\'))"