Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[System.Collections.Hashtable] $SevenDigitDisplay = @{
  0 = "abcefg"
  1 = "cf"
  2 = "acdeg"
  3 = "acdfg"
  4 = "bcdf"
  5 = "abdfg"
  6 = "abdefg"
  7 = "acf"
  8 = "abcdefg"
  9 = "abcdfg"
}
[string[]] $OutputValues = @()

# [string[]] $DataInput = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $DataInput = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$DataInput.ForEach( { $OutputValues += $_.Split("|")[1].Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries) })
$OutputValues.Where( { $_.Length -in $SevenDigitDisplay[1,4,7,8].ForEach( { $_.Length }) } ).Count
# Correct answer = 390 (26 for testdata)
