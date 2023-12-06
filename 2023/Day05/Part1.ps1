Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[Int64] $Result = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
for ($i = 0; $i -lt $Data.Count; $i++) {
  $DataLine = $Data[$i]
  if ($i -eq 0) {[Int64[]]$Seeds = $DataLine.Split(':')[1].Trim().Split()}
  elseif ($DataLine -eq '') {}
  elseif ($DataLine.EndsWith('map:')) {$SeedsHandled = @($false) * $Seeds.Count}
  else {
    [Int64]$RangeDestination, [Int64]$RangeSource, [Int64]$RangeLength = $DataLine.Split()
    for ($j = 0; $j -lt $Seeds.Count; $j++) {
      if (!$SeedsHandled[$j] -and $Seeds[$j] -ge $RangeSource -and $Seeds[$j] -lt $RangeSource+$RangeLength) {
        $Seeds[$j] += $RangeDestination - $RangeSource
        $SeedsHandled[$j] = $true
      }
    }
  }
}
$Result = ($seeds | Measure-Object -Minimum).Minimum

Write-Host $Result
# Correct answer = 289863851 (35 for testdata)