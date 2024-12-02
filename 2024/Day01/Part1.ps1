Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0
$Left = @()
$Right = @()

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
foreach ($DataLine in $Data) {
  $Left += $DataLine.Split('   ')[0]
  $Right += $DataLine.Split('   ')[1]
}
$Left = $Left | Sort-Object
$Right = $Right | Sort-Object
for ($i = 0; $i -lt $Left.Count; $i++) {
  $Result += [System.Math]::Abs($Left[$i] - $Right[$i])
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 1530215 (11 for testdata)