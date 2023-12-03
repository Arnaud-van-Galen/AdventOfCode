Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int] $Result = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
for ($i = 0; $i -lt $Data.Count; $i++) {
  $DataLine = $Data[$i]
  $PossiblePartNumbers = [Regex]::Matches($DataLine, '\d+')
  $PossiblePartNumbers.ForEach{
    $AdjacentToSymbol = $false
    if ($i -gt 0) {if (('.'+$Data[$i-1]+'.').Substring($_.Index,$_.Length+2) -match '[^\.\d]') {$AdjacentToSymbol = $true}} # CheckAbove
    if (('.'+$Data[$i]+'.').Substring($_.Index,$_.Length+2) -match '[^\.\d]') {$AdjacentToSymbol = $true} # CheckLeftRight
    if ($i -lt $Data.Count - 1) {if (('.'+$Data[$i+1]+'.').Substring($_.Index,$_.Length+2) -match '[^\.\d]') {$AdjacentToSymbol = $true}} # CheckBelow
    if ($AdjacentToSymbol) {$Result += $_.Value}
  }
}

Write-Host $Result
# Correct answer = 514969 (4361 for testdata)