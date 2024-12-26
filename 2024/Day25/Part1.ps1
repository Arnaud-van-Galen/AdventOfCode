Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
Set-StrictMode -Version Latest
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$Result = 0
$GridWidth = $Data[0].Length
$Keys = [int[]]@()
$Locks = [int[]]@()

$Schematics = ($Data -join ',').Split(',,').Replace(',','') # Group as strings of length 35 (5*7)
$MaximumHeight = $Schematics[0].Length / $GridWidth -2 # GridHeight -2 because the first and last row are not for pins
foreach ($Schematic in $Schematics) {
	$Pins = ,(-1) * $GridWidth
	for ($i = 0; $i -lt $Schematic.Length; $i++) { if ($Schematic[$i] -eq '#') { $Pins[$i % $GridWidth]++ } }
	if ($Schematic[0] -eq '#') { $locks += ,$Pins } else { $Keys += ,$Pins } # Locks start with a (row of) #
}

foreach ($Key in $Keys) {
	foreach ($Lock in $Locks) {
		$CanFit = $true
		for ($i = 0; $i -lt $GridWidth; $i++) {
			if ($Key[$i] + $Lock[$i] -gt $MaximumHeight) { $CanFit = $false ; continue }
		}
		 if ($CanFit) { $Result++ }
	}
}

# Get-MyVariables
Write-Host 'Time for calculating:', $stopwatch.Elapsed.TotalSeconds
Write-Host 'Calculated answer:', $Result
Write-Host 'Correct answer: 2933 (3 for testdata)'
Write-Host 'To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('C:','/mnt/c').Replace('\','/')
Write-Host 'To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('/mnt/c','C:').Replace('/','\')