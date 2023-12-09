Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0

# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
for ($i = 0; $i -lt $Data.Count; $i++) {
  $HistoryLines = [System.Collections.ArrayList]::new()
  $HistoryLines.Add([int[]]($Data[$i].Split(' '))) | Out-Null
  while ($HistoryLines[-1].ForEach{$_ -ne 0} | Select-Object -Unique) {
    $HistoryLineNext=@()
    for ($j = 1; $j -lt $HistoryLines[-1].Count; $j++) {
      $HistoryLineNext+=$HistoryLines[-1][$j]-$HistoryLines[-1][$j-1]
    }
    $HistoryLines.Add($HistoryLineNext) | Out-Null
  }
  $HistoryLines.ForEach{$Result+=$_[-1]}
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 1806615041 (114 for testdata)