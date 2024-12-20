Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

[Int64] $Result = 0
$ThanksForHelpingMeRememberGio = @{}
function RecursivelyFind { param ( [string]$Design )
	if ($ThanksForHelpingMeRememberGio.ContainsKey($Design)) { return $ThanksForHelpingMeRememberGio[$Design] } # Try to retrieve from cache
	if ($Design -eq "") { return 1 }
	$Count = 0

	foreach ($Towel in $Towels) {	if ($Design.StartsWith($Towel)) { $Count += RecursivelyFind($Design.Substring($Towel.Length)) } }

	$ThanksForHelpingMeRememberGio[$Design] = $Count # Add to cache
	return $Count
}

$Towels = $Data[0].Split(', ')
for ($i = 2; $i -lt $Data.Count; $i++) {
	$Result += (RecursivelyFind -Design $Data[$i]) -ne 0
}

# Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host "Calculated answer: $Result"
Write-Host "Correct answer: 285 (6 for testdata)"
Write-Host "To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('C:','/mnt/c').Replace('\','/'))"
Write-Host "To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('/mnt/c','C:').Replace('/','\'))"