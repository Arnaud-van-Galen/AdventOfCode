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
for ($i = 0; $i -lt $Left.Count; $i++) {
  $Result += $Right.Where{$_ -eq $Left[$i]}.Count * $Left[$i]
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 54159 (142 for testdata)