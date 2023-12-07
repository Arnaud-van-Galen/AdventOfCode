Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0
$ExtraCardValues = @{T=10;J=1;Q=12;K=13;A=14}
$Strengths = @{'11111'=1;'2111'=2;'221'=3;'311'=4;'32'=5;'41'=6;'5'=7}
$Hands = @{}

# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
foreach ($DataLine in $Data) {
  [string]$Hand, [int]$Bid = $DataLine.split(' ')
  [int[]]$Cards = $Hand.ToCharArray().ForEach{$ExtraCardValues[$_.tostring()] ?? $_.ToString()}
  $GroupedCards = $Cards.Where{$_ -ne $ExtraCardValues['J']} | Group-Object | Sort-Object -Property Count, Name -Descending
  if (!$GroupedCards) { $GroupedCards = $Cards | Group-Object | Sort-Object -Property Count, Name -Descending }
  $CardsOptimized = $Cards.ForEach{$_ -eq $ExtraCardValues['J'] ? $GroupedCards[0].name : $_ }
  $GroupedCardsOptimized = $CardsOptimized | Group-Object | Sort-Object -Property Count, Name -Descending
  $Strength = $Strengths[$GroupedCardsOptimized.ForEach{$_.Count} -join'']
  $Hands[$Strength.ToString() + ($Cards.ForEach{$_.ToString().PadLeft(2,'0')} -join '')] = $Bid
}
$RankedHands = $Hands.Keys | Sort-Object
for ($i = 0; $i -lt $RankedHands.Count; $i++) { $Result += ($i+1)*$Hands[$RankedHands[$i]] }

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 251224870 (5905 for testdata)