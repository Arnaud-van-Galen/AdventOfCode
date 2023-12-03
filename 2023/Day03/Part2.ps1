Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int] $Result = 0
$AdjacentGears = @()

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
for ($i = 0; $i -lt $Data.Count; $i++) {
  $DataLine = $Data[$i]
  $PossiblePartNumbers = [Regex]::Matches($DataLine, '\d+')
  $PossiblePartNumbers.ForEach{
    $PossiblePartNumber = $_
    if ($i -gt 0) {([Regex]::Matches(('.'+$Data[$i-1]+'.').Substring($_.Index,$_.Length+2), '[\*]')).ForEach{
      $AdjacentGears += [PSCustomObject]@{ y = $i-1; x = $PossiblePartNumber.Index-1+$_.Index; value = $PossiblePartNumber.Value}
    }}
    [Regex]::Matches(('.'+$Data[$i]+'.').Substring($_.Index,$_.Length+2), '[\*]').ForEach{
      $AdjacentGears += [PSCustomObject]@{ y = $i; x = $PossiblePartNumber.Index-1+$_.Index; value = $PossiblePartNumber.Value}
    } 
    if ($i -lt $Data.Count - 1) {([Regex]::Matches(('.'+$Data[$i+1]+'.').Substring($_.Index,$_.Length+2), '[\*]')).ForEach{
      $AdjacentGears += [PSCustomObject]@{ y = $i+1; x = $PossiblePartNumber.Index-1+$_.Index; value = $PossiblePartNumber.Value}
    }}
  }
}
$RelevantGears = $AdjacentGears | Group-Object y,x | Where-Object {$_.Count -eq 2}
$RelevantGears.ForEach{$Result += [int]$_.Group.value[0] * [int]$_.Group.value[1]}

Write-Host $Result
# Correct answer = 78915902 (467835 for testdata)