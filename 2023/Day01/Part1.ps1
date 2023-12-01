Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int] $Result = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
foreach ($DataLine in $Data) {
    $Result += $DataLine.ToCharArray().Where{$_-48 -in @(0..9)}[0..-1] -join ''
}

Write-Host $Result
# Correct answer = 69883 (24000 for testdata)