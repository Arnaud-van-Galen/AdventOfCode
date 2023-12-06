Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int] $Result = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo2.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
$ExtraMatches = @{one=1;two=2;three=3;four=4;five=5;six=6;seven=7;eight=8;nine=9}
foreach ($DataLine in $Data) {
  $FirstAndLast = [Regex]::Matches($DataLine, '(?=(\d|'+ ($ExtraMatches.Keys -join '|') +'))')[0..-1]
  $Result += ($FirstAndLast.ForEach{$ExtraMatches[$_.Groups[1].Value] ?? $_.Groups[1].Value} -join '')
}

Write-Host $Result
# Correct answer = 53866 (281 for testdata)