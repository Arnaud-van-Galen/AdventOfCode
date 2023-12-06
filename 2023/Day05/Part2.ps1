Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[Int64] $Result = 0
$SeedRanges = @()
$SeedRangesNext = @()
$MapCounter = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
for ($i = 0; $i -lt $Data.Count; $i++) {
  $DataLine = $Data[$i]
  if ($i -eq 0) {
    [Int64[]]$SeedsInfo = $DataLine.Split(':')[1].Trim().Split()
    for ($j = 0; $j -lt $SeedsInfo.Count; $j = $j+2) {$SeedRanges += [PSCustomObject]@{ Min = $SeedsInfo[$j]; Max = $SeedsInfo[$j]+$SeedsInfo[$j+1]-1; NextMapToProcess = 0}}}
  elseif ($DataLine -eq '') {}
  elseif ($DataLine.EndsWith('map:')) {
    $SeedRanges = $SeedRanges.Where{$MapCounter -eq $_.NextMapToProcess}
    $MapCounter++
    $SeedRanges.ForEach{$_.NextMapToProcess = $MapCounter}
    $SeedRanges += $SeedRangesNext
    $SeedRangesNext = @()}
  else {
    [Int64]$RangeDestination, [Int64]$RangeSourceMin, [Int64]$RangeLength = $DataLine.Split()
    $RangeSourceMax = $RangeSourceMin + $RangeLength - 1
    $RangeOffset = $RangeDestination - $RangeSourceMin
    for ($j = 0; $j -lt $SeedRanges.Count; $j++) {
      $SeedRange = [PSCustomObject]@{ Min = $SeedRanges[$j].Min; Max = $SeedRanges[$j].Max; NextMapToProcess = $SeedRanges[$j].NextMapToProcess}
      if ($MapCounter -eq $SeedRange.NextMapToProcess) {
        if ($SeedRange.Max -lt $RangeSourceMin -or $SeedRange.Min -gt $RangeSourceMax) {
          # Write-Host "No overlap between $($SeedRange.Min), $($SeedRange.Max) and $RangeSourceMin, $RangeSourceMax"
        } elseif ($SeedRange.Max -le $RangeSourceMax -and $SeedRange.Min -ge $RangeSourceMin) {
          # Write-Host "Full overlap between $($SeedRange.Min), $($SeedRange.Max) and $RangeSourceMin, $RangeSourceMax. Moving by $RangeOffset"
          $SeedRanges[$j].NextMapToProcess = $MapCounter + 1
          $SeedRangesNext += [PSCustomObject]@{ Min = $SeedRange.Min + $RangeOffset; Max = $SeedRange.Max + $RangeOffset; NextMapToProcess = $MapCounter + 1}
        } elseif ($SeedRange.Max -gt $RangeSourceMax -and $SeedRange.Min -lt $RangeSourceMin) {
          # Write-Host "Partial overlap between $($SeedRange.Min), $($SeedRange.Max) and $RangeSourceMin, $RangeSourceMax but remainder on both sides. Moving by $RangeOffset"
          $SeedRanges[$j].Max = $RangeSourceMin - 1
          $SeedRanges += [PSCustomObject]@{ Min = $RangeSourceMax + 1 ; Max = $SeedRange.Max; NextMapToProcess = $MapCounter}
          $SeedRangesNext += [PSCustomObject]@{ Min = $RangeSourceMin + $RangeOffset; Max = $RangeSourceMax + $RangeOffset; NextMapToProcess = $MapCounter + 1}
        } elseif ($SeedRange.Max -le $RangeSourceMax) {
          # Write-Host "Partial overlap between $($SeedRange.Min), $($SeedRange.Max) and $RangeSourceMin, $RangeSourceMax but remainder on left. Moving by $RangeOffset"
          $SeedRanges[$j].Max = $RangeSourceMin - 1
          $SeedRangesNext += [PSCustomObject]@{ Min = $RangeSourceMin + $RangeOffset; Max = $SeedRange.Max + $RangeOffset; NextMapToProcess = $MapCounter + 1}
        } else {
          # Write-Host "Partial overlap between $($SeedRange.Min), $($SeedRange.Max) and $RangeSourceMin, $RangeSourceMax but remainder on right. Moving by $RangeOffset"
          $SeedRanges[$j].Min = $RangeSourceMax + 1
          $SeedRangesNext += [PSCustomObject]@{ Min = $SeedRange.Min + $RangeOffset; Max = $RangeSourceMax + $RangeOffset; NextMapToProcess = $MapCounter + 1}
        }
      }
    }
  }
}
$SeedRanges = $SeedRanges.Where{$MapCounter -eq $_.NextMapToProcess}
$SeedRanges += $SeedRangesNext
$Result = ($SeedRanges.Min | Measure-Object -Minimum).Minimum

Write-Host $Result
# Correct answer = 60568880 (46 for testdata)