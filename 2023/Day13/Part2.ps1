Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0
$GridTop, $GridBottom = 0, 0

function TryHorizontalCut { param ($iCutToSkip)
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
    if ($PerfectReflection -and ($iCutToSkip -ne $iCut)) {
      return [psobject]@{
        iCut = $iCut
        iCutValue = $iCut*100
        Source = "Horizontal"
        Puzzel = $i
      }
    }
  }
  return $null
}

function TryVerticalCut { param ($iCutToSkip)

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
    $PerfectReflection = $true
    for ($r = 0; $r -lt $grid.Count; $r++) {
      $LeftString = $grid[$r][($iCut-1)..$Left] -join ''
      $RightString = $grid[$r][$iCut..$Right] -join ''
      if ($LeftString -ne $RightString) {
        $PerfectReflection = $false
        break;
      }
    }
    if ($PerfectReflection -and ($iCutToSkip -ne $iCut)) {
      return [psobject]@{
        iCut = $iCut
        iCutValue = $iCut
        Source = "Vertical"
        Puzzel = $i
      }
    }
  }
  return $null
}


# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo2.txt -ErrorAction Stop
[string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
$Data += '`n'
for ($i = 0; $i -lt $Data.Count; $i++) {
  if ($Data[$i] -eq '' -or $i -eq $Data.Count-1) {
    $GridBottom = $i-1
    $Grid = $Data[$GridTop..($GridBottom)]

    $orgResultH = TryHorizontalCut
    $orgResultV = TryVerticalCut
    $orgResult = $orgResultH ?? $orgResultV

    :modifygrid for ($ra = 0; $ra -lt $Grid.Count; $ra++) {
      for ($ca = 0; $ca -lt $Grid[$ra].Length; $ca++) {
        $Grid = $Data[$GridTop..($GridBottom)]
        if ($grid[$ra][$ca] -eq '#') {
          $Grid[$ra] = $Grid[$ra].Remove($ca,1).Insert($ca,'.')
        } else {
          $Grid[$ra] = $Grid[$ra].Remove($ca,1).Insert($ca,'#')
        }
        
        $FoundNew = $false
        if ($orgResult.Source -eq 'Horizontal') {
          $newResult = TryHorizontalCut -iCutToSkip $orgResult.iCut
        } else {
          $newResult = TryHorizontalCut
        }
        if ($newResult) {
          if ((compare-object ($orgResult | ConvertTo-Json) ($newResult | ConvertTo-Json)).Count -ne 0) {
            $FoundNew = $true
            $Result += $newResult.iCutValue
            break modifygrid
          }
        }
        if (!$FoundNew) {
          if ($orgResult.Source -eq 'Vertical') {
            $newResult = TryVerticalCut -iCutToSkip $orgResult.iCut
          } else {
            $newResult = TryVerticalCut
          }          if ($newResult) {
            if ((compare-object ($orgResult | ConvertTo-Json) ($newResult | ConvertTo-Json)).Count -ne 0) {
              $FoundNew = $true
              $Result += $newResult.iCutValue
              break modifygrid
            }
          }
        }
      }
    }
    $GridTop = $i+1
  }
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 33054 (400 for testdata)