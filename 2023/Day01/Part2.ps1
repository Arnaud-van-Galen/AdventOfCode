Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int] $Result = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo2.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
$ExtraMatches = @{'one'=1;'two'=2;'three'=3;'four'=4;'five'=5;'six'=6;'seven'=7;'eight'=8;'nine'=9}
foreach ($DataLine in $Data) {
  $FirstAndLastIndex = ([Regex]::new('(?=\d|'+ ($ExtraMatches.Keys -join '|') +')').Matches($DataLine)*2)[0..-1].Index
  $Result += ($FirstAndLastIndex.ForEach{
    if ([char]::IsNumber($DataLine[$_])) {$DataLine[$_]} else {
      $Index=$_
      $ExtraMatches.Keys.ForEach{if ($DataLine.Substring($Index).StartsWith($_)) {$ExtraMatches[$_]}}
    }
  } -join '')
}

Write-Host $Result
# Correct answer = 53866 (281 for testdata)