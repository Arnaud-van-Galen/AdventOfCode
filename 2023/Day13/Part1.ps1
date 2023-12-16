Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0
$GridTop, $GridBottom = 0, 0

# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
$Data += '`n'
for ($i = 0; $i -lt $Data.Count; $i++) {
  if ($Data[$i] -eq '' -or $i -eq $Data.Count-1) {
    $GridBottom = $i-1
    $Grid = $Data[$GridTop..($GridBottom)]

    # TryHorizontalCut, giving top (lower) and bottom (higher)
    $GridRows = $Grid.Count
    $FoldCount = $GridRows - 1
    for ($iCut = 1; $iCut -le $FoldCount; $iCut++) {
      $PerfectReflection = $true
      for ($iCutCompare = $iCut; $iCutCompare -gt 0; $iCutCompare--) {
        $Total = $iCut*2-1
        $Lower = $iCutCompare-1
        $Higher = $Total-$Lower
        if ($Higher -lt $GridRows) {
          $Top = $Grid[$Lower]
          $Bottom = $Grid[$Higher]
          if ($Top -ne $Bottom) {
            $PerfectReflection = $false
            break;
          }
        }
      }
      if ($PerfectReflection) {$Result+=$iCut*100}
    }

    # TryVerticalCut, giving left (lower) and right (higher)
    $GridColumns = $Grid[0].Length
    $FoldCount = $GridColumns - 1
    for ($iCut = 1; $iCut -le $FoldCount; $iCut++) {
      $Left = $iCut -1
      $Right = $iCut
      while ($Left -gt 0 -and $Right -lt $FoldCount) {
        $Left--
        $Right++
      }
      # Write-Host "$GridColumns columns, cut at $iCut, Left=$Left tot $($icut-1), Right=$icut tot $Right"
      $PerfectReflection = $true
      for ($r = 0; $r -lt $grid.Count; $r++) {
        $LeftString = $grid[$r][($iCut-1)..$Left] -join ''
        $RightString = $grid[$r][$iCut..$Right] -join ''
        if ($LeftString -ne $RightString) {
          $PerfectReflection = $false
          break;
        }
      }
      if ($PerfectReflection) {$Result+=$iCut}
    }
    $GridTop = $i+1
  }
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 34918 (405 for testdata)