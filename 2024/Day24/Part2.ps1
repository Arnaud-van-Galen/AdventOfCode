Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
Set-StrictMode -Version Latest
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo3.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$GateLines = $data.Where{ $_ -match '->'}
$BadGateLines = $GateLines.Where{ $_ -notmatch '[a-z]{3} XOR [a-z]{3} -> z\d{2}|[xy]\d{2} AND [xy]\d{2} -> [a-z]{3}|[xy]\d{2} XOR [xy]\d{2} -> [a-z]{3}|[a-z]{3} OR [a-z]{3} -> [a-z]{3}|[a-z]{3} AND [a-z]{3} -> [a-z]{3}' }
$BadWires =  $BadGateLines.ForEach{ $_.Split(' -> ')[1] } | Sort-Object
Write-Host "This is actually a REALLY good way to get started to find the bad gatelines! It will find 6 out of 8 correctly. $(($BadWires -join ','))"

$FoundInExcel = 'ggn, z10, jcb, ndw, grm, z32, twr, z39'
$Reordered = $FoundInExcel.Split(',').Trim() | Sort-Object

# Get-MyVariables
Write-Host 'Time for calculating:', $stopwatch.Elapsed.TotalSeconds
Write-Host 'Calculated answer:', ($Reordered -join ',')
Write-Host 'Correct answer: ggn,grm,jcb,ndw,twr,z10,z32,z39'
Write-Host 'To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('C:','/mnt/c').Replace('\','/')
Write-Host 'To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('/mnt/c','C:').Replace('/','\')