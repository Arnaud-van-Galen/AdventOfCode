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
$RightGrouped = @{}
($Right | Group-Object -NoElement).foreach{$RightGrouped[$_.Name] = $_.Count}
for ($i = 0; $i -lt $Left.Count; $i++) {
  $Result += $RightGrouped[$Left[$i]] * $Left[$i]
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 26800609 (31 for testdata)