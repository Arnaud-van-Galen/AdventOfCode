Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0
$ReplaceInput = @{'?'='U';'#'='B';'.'='W'} # The original input had characters that are hard to handle in regex so I replace them with Unknown, Black, White

# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
foreach ($DataLine in $Data) {
  $Puzzle, $SolutionString = $DataLine.Split(' ')
  $ReplaceInput.Keys.ForEach{$Puzzle = $Puzzle.Replace($_,$ReplaceInput[$_])}
  $SolutionArray = $SolutionString.Split(',')
  $SolutionAnalysis = $SolutionArray | Measure-Object -Sum

  
  $SolutionPattern = '^(U|W)*'
  for ($i = 0; $i -lt $SolutionArray.Count-1; $i++) {
    $SolutionPattern += "(B|U){$($SolutionArray[$i])}(U|W)+"
  }
  $SolutionPattern += "(B|U){$($SolutionArray[-1])}(U|W)*$"
  
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
    # BruteForce
    $Unknowns = [Regex]::Matches($Puzzle, 'U')
    $UnknownsCount = $Unknowns.Count
    $BlacksCount = $SolutionAnalysis.Sum - [regex]::Matches($Puzzle,'B').Count
    $CurrentCombination = ''
    $Stack = [System.Collections.Stack]::New()
    $Stack.Push(($UnknownsCount, $BlacksCount, $CurrentCombination))
    
    while ($Stack.Count -gt 0) {
      $UnknownsCount, $BlacksCount, $CurrentCombination = $Stack.Pop()
      if ($UnknownsCount -eq 0) {
        $Puzzle_ = $Puzzle.ToCharArray()
        for ($i = 0; $i -lt $Unknowns.Count; $i++) {
          $Puzzle_[$Unknowns[$i].Index] = $CurrentCombination[$i]
        }
        if ([regex]::Matches($Puzzle_ -join '', 'B+').Length -join ',' -eq $SolutionString) {$Result++}
      } else {
        if ($BlacksCount -gt 0) {
          $Stack.Push((($UnknownsCount - 1), ($BlacksCount - 1), ($CurrentCombination + 'B')))
        }
        if ($UnknownsCount - $BlacksCount -gt 0) {
          $Stack.Push((($UnknownsCount - 1), $BlacksCount, ($CurrentCombination + 'W')))
        }
      }
    }
  }
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 6958 (21 (1,4,1,1,4,10) for testdata)