Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0
$Cards = @{}

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
for ($i = 0; $i -lt $Data.Count; $i++) {
  $CardNumber, $CardInfo = $Data[$i].Split(':').Trim()
  $Winning, $Mine = $CardInfo.Split('|').Trim()
  $Comparison =  Compare-Object $Winning.Split() $Mine.Split() -IncludeEqual
  $WinCount = $Comparison.Where{$_.SideIndicator -eq '==' -and $_.InputObject.Trim() -ne ''}.Count
  $Cards[$i] = $Cards[$i] +1
  for ($WinCard = 0; $WinCard -lt $WinCount; $WinCard++) {$cards[$i+$WinCard+1] += $Cards[$i]}
  $Result += $Cards[$i]
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 19499881 (30 for testdata)