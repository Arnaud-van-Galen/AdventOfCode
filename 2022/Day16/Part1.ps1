Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
# [string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop



# Correct answer = 4724228 (26 for testdata)

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds