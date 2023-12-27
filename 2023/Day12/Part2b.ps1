Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0
$multiplyfactor = 3
$ReplaceInput = @{'?'='U';'#'='B';'.'='W'} # The original input had characters that are hard to handle in regex so I replace them with Unknown, Black, White

$ProgressCount = 0
# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
foreach ($DataLine in $Data) {
  $Puzzle, $SolutionString = $DataLine.Split(' ')
  $Puzzle = @($Puzzle)*$multiplyfactor -join '?'
  $SolutionString = @($SolutionString)*$multiplyfactor -join ','
  $ReplaceInput.Keys.ForEach{$Puzzle = $Puzzle.Replace($_,$ReplaceInput[$_])}
  $SolutionArray = $SolutionString.Split(',')
  
  $SolutionPattern = '^(U|W)*'
  for ($i = 0; $i -lt $SolutionArray.Count-1; $i++) {
    $SolutionPattern += "(B|U){$($SolutionArray[$i])}(U|W)+"
  }
  $SolutionPattern += "(B|U){$($SolutionArray[-1])}(U|W)*$"
  
  # Try all the tiles one by one to simply the puzzle
  $SomethingImproved = $true
  while ($SomethingImproved -and $Puzzle.Contains('U')) {
    $SomethingImproved = $false
    $Unknowns = [Regex]::Matches($Puzzle, 'U')
    for ($i = 0; $i -lt $Unknowns.Count; $i++) {
      $Index = $Unknowns[$i].Index
      $Puzzle = $Puzzle.Remove($Index, 1).Insert($Index, 'W')
      if (![Regex]::Matches($Puzzle, $SolutionPattern)) { # Test White
        $Puzzle = $Puzzle.Remove($Index, 1).Insert($Index, 'B') # Not White, so surely Black
        $SomethingImproved = $true
      } else {
        $Puzzle = $Puzzle.Remove($Index, 1).Insert($Index, 'B') # Maybe White
        if (![Regex]::Matches($Puzzle, $SolutionPattern)) { # Test Black
          $Puzzle = $Puzzle.Remove($Index, 1).Insert($Index, 'W') # Not Black, so surely White
          $SomethingImproved = $true
        } else {
          $Puzzle = $Puzzle.Remove($Index, 1).Insert($Index, 'U') # Maybe White, Maybe Black, so back to Unknown
        }
      }
    }
  }

  if (!$Puzzle.Contains('U')) {
    $Result++
  } else {
    $HasBroken = $false # To keep it simple, only break the first (biggest) one that is fully done
    $SolutionGroups = $SolutionArray | Group-Object -NoElement | Sort-Object Name -Descending
    for ($i = 0; $i -lt $SolutionGroups.Length -and !$HasBroken; $i++) {
      $SolvedGroups = [Regex]::Matches($Puzzle, "(?:^|W)(B{$($SolutionGroups[$i].Name)})(?:W|$)")
      if ($SolvedGroups.Count -eq $SolutionGroups[$i].Count) {
        $PuzzleSplittable = $Puzzle
        $SolvedGroups.ForEach{$PuzzleSplittable = $PuzzleSplittable.Remove($_.Groups[1].Index, $_.Groups[1].Length).Insert($_.Groups[1].Index, " "*$_.Groups[1].Length)}
        $PuzzleSplittable = $PuzzleSplittable -replace " {$($SolutionGroups[$i].Name)}", ' '
        $SolutionStringSplittable = $SolutionString -replace "\b$($SolutionGroups[$i].Name)\b", ' '
        $HasBroken = $true
      }
    }
    if ($HasBroken) { # Sometimes breaks leave pieces without Unknowns or digits. These can be safely removed
      $PuzzlePieces = $PuzzleSplittable.Split(' ')
      $SolutionStringPieces = $SolutionStringSplittable.Split(' ')
      if ($PuzzlePieces.Count -ne $SolutionStringPieces.Count) {
        Write-Error "this should not happen"
      } else {
        for ($i = 0; $i -lt $PuzzlePieces.Count; $i++) {
          $PuzzlePieceTest = $PuzzlePieces[$i].Trim()
          $SolutionStringPieceTest = $SolutionStringPieces[$i].Trim(',')
          if ($PuzzlePieceTest.Contains('U') -and $SolutionStringPieceTest -match '\d') {
            $PuzzlePieces[$i] = $PuzzlePieceTest
            $SolutionStringPieces[$i] = $SolutionStringPieceTest
          } else {
            $PuzzlePieces[$i] = 'INVALID'
            $SolutionStringPieces[$i] = 'INVALID'
          }
        }
      }
      $PuzzlePieces = $PuzzlePieces.Where{$_ -ne 'INVALID'}
      $SolutionStringPieces = $SolutionStringPieces.Where{$_ -ne 'INVALID'}
    } else {
      $PuzzlePieces = @($Puzzle)
      $SolutionStringPieces = @($SolutionString)
    }
    $ResultPieces = 1
    for ($p = 0; $p -lt $PuzzlePieces.Count; $p++) {
      # BruteForce
      $PuzzlePiece = $PuzzlePieces[$p]
      $SolutionStringPiece = $SolutionStringPieces[$p]

      $Stack = [System.Collections.Stack]::New()
      $Stack.Push(($PuzzlePiece, $SolutionStringPiece.Split(','), ([int]$ResultPiece = 0)))
      while ($Stack.Count -gt 0) {
        [string]$PuzzlePiece, [int[]]$SolutionArrayPiece, [int]$currentResultPiece = $Stack.Pop()
        # If there are no more blacks in the solution that is only okay if there are no more blacks in the puzzle as well
        if (!$SolutionArrayPiece) {
          if ($PuzzlePiece -notmatch 'B') {$currentResultPiece++}
        } else {
          [string]$SolutionPattern = '^[UW]*'
          for ($i = 0; $i -lt $SolutionArrayPiece.Count-1; $i++) {
            $SolutionPattern += "([BU]{$($SolutionArrayPiece[$i])})[UW]+"
          }
          $SolutionPattern += "([BU]{$($SolutionArrayPiece[-1])})[UW]*$"
          if ([Regex]::Matches($PuzzlePiece, $SolutionPattern, 'RightToLeft').Count -gt 0) {
            [int]$StartPositionMin = [Regex]::Matches($PuzzlePiece, $SolutionPattern, 'RightToLeft').Groups[1].Index
            [int]$StartPositionMax = [Regex]::Matches($PuzzlePiece, $SolutionPattern).Groups[1].Index

            for ($StartPosition = $StartPositionMin; $StartPosition -le $StartPositionMax; $StartPosition++) {
              [int]$EndPosition = $StartPosition + ($SolutionArrayPiece[0] -1)
              [bool]$BlacksBeforeStartPosition = [Regex]::Matches($PuzzlePiece,'B').Where{$_.Index -lt $StartPosition}.Count -gt 0
              [bool]$BlacksDirectlyAfterEndPosition = [Regex]::Matches($PuzzlePiece,'B').Where{$_.Index -eq ($EndPosition+1)}.Count -gt 0
              [bool]$WhitesInRange = [Regex]::Matches($PuzzlePiece,'W').Where{$_.Index -in @($StartPosition..$EndPosition)}.Count -gt 0
              if (!$BlacksBeforeStartPosition -and !$BlacksDirectlyAfterEndPosition -and !$WhitesInRange) {
                # Black group possibility found! Continue 1 group further
                [string]$PuzzlePieceNext = $PuzzlePiece.Substring([System.Math]::Min($EndPosition+2, $PuzzlePiece.Length))
                [int[]]$SolutionArrayPieceNext = $SolutionArrayPiece | Select-Object -SkipIndex 0
                $Stack.Push(($PuzzlePieceNext, $SolutionArrayPieceNext, $currentResultPiece))
              }
            }
          }
        }
        $ResultPiece += $currentResultPiece
      }
      $ResultPieces*=$ResultPiece
    }
    $Result += $ResultPieces
  }
  $ProgressCount++
  Write-Host "$ProgressCount, $Result, $($stopwatch.Elapsed.TotalSeconds)"
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 6958 (525152 (1,16384,1,16,2500,506250) for testdata)