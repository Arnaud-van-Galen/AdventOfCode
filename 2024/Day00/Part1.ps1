Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[Int64] $Result = 0

$Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
# $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

foreach ($DataLine in $Data) {

}

Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = ??? (XXX for testdata)