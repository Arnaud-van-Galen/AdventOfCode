Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
for ($i = 0; $i -lt $Data.Count; $i++) {
  $CardNumber, $CardInfo = $Data[$i].Split(':').Trim()
  $Winning, $Mine = $CardInfo.Split('|').Trim()
  $Comparison =  Compare-Object $Winning.Split() $Mine.Split() -IncludeEqual
  $WinCount = $Comparison.Where{$_.SideIndicator -eq '==' -and $_.InputObject.Trim() -ne ''}.Count
  $Result += [Math]::Floor([Math]::Pow(2, $WinCount-1))
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 25651 (13 for testdata)