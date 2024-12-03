Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -Raw -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -Raw -ErrorAction Stop

$ValidData = [Regex]::new("mul\(\d{1,3},\d{1,3}\)").Matches($Data).Value
$ValidData.ForEach{
  [int]$a, [int]$b = $_.TrimStart('mul(').TrimEnd(')').Split(',')
  $Result += $a*$b
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 165225049 (161 for testdata)