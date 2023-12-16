Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

$bits = 5
$numB = 2
$totalCombinations = [math]::Pow(2, $bits)
$counter=0
# for ($i = 0; $i -lt $totalCombinations; $i++) {
#   # if ([convert]::ToString($i, 2).ToCharArray().Where{$_ -eq 49}.Count -eq $numB) {$counter++}
#   # if ([regex]::matches([convert]::ToString($i, 2), '1').Count -eq $numB) {$counter++}
#   $number = $i
#   $countB = 0
#   while ($number -ne 0){#} -and $countB -le $numB) {
#     $number = $number -band $number - 1
#     $countB++
#   }
#   if ($countB -eq $numB) {$counter++}#$number -eq 0 -and 
# }
# $counter
#20,3 (1140): chararray = 42sec, regex = 16 sec, chararray 42, band-escaped = 8 sec, band = 13 sec, recursive/stack = 0,1
#20,10 (184756): chararray = 42 sec, regex = 16 sec, band-escaped = 16 sec = 13sec, recursive/stack = 0,1

# $totalLength = 20
# $numB = 10
# $StoreSize = 1
# for ($i = $totalLength; $i -gt ($totallength-$numB); $i--) { $StoreSize *= $i }
# for ($i = $numB; $i -gt 0; $i--) { $StoreSize /= $i }
# $Store = @(,@())*$StoreSize
# $ActiveStore = 0
# $CurrentCombination = $Store[$ActiveStore]
# $stack = New-Object 'System.Collections.Stack'
# $stack.Push(($totalLength, $numB, $currentCombination))

# while ($stack.Count -gt 0) {
#     $totalLength, $numB, $currentCombination = $stack.Pop()

#     if ($totalLength -eq 0) {
#         $Store[$ActiveStore] = $CurrentCombination
#         $ActiveStore++
#     } else {
#         if ($numB -gt 0) {
#             $stack.Push((($totalLength - 1), ($numB - 1), ($currentCombination + $true)))
#         }
#         if ($totalLength - $numB -gt 0) {
#             $stack.Push((($totalLength - 1), $numB, ($currentCombination + $false)))
#         }
#     }
# }

[int] $Result = 0
$multiplyfactor = 1
$Results = @()
$ReplaceInput = @{'?'='U';'#'='B';'.'='W'} # The original input had characters that are hard to handle in regex so I replace them with Unknown, Black, White

# Write-Host "Puzzel|Oplossing|Puzzellengte|Zwart aantal blokken|Zwart aantal totaal|Zwart kleinste blok|Zwart grootste blok|Onbekend aantal|Onbekend blokken"
# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
foreach ($DataLine in $Data) {
  $Puzzle, $SolutionString = $DataLine.Split(' ')
  $Puzzle = @($Puzzle)*$multiplyfactor -join '-'
  $SolutionString = @($SolutionString)*$multiplyfactor -join ','
  $ReplaceInput.Keys.ForEach{$Puzzle = $Puzzle.Replace($_,$ReplaceInput[$_])}
  $Solution = $SolutionString.Split(',')
  $PuzzleLength = $Puzzle.Length
  $PuzzleBlacks = [regex]::Matches($Puzzle,'B')
  $PuzzleUnknowns = [regex]::Matches($Puzzle,'U')
  $PuzzleUnknownsContinuous = [regex]::Matches($Puzzle,'U+')
  $SolutionAnalysis = $Solution | Measure-Object -Sum -Maximum -Minimum
  # Write-Host $Puzzle,'|',$Solution,'|',$PuzzleLength,'|',$Solution.Count,'|',$SolutionAnalysis.Sum,'|',$SolutionAnalysis.Minimum,'|',$SolutionAnalysis.Maximum,'|',$PuzzleUnknowns.Count,'|',($PuzzleUnknownsContinuous.Length -join ',')
  
  # BruteForce
  # <#
  $totalLength = $PuzzleUnknowns.Count
  $numB = $SolutionAnalysis.Sum - $PuzzleBlacks.Count
  $StoreSize = 1
  for ($i = $totalLength; $i -gt ($totallength-$numB); $i--) { $StoreSize *= $i }
  for ($i = $numB; $i -gt 0; $i--) { $StoreSize /= $i }
  $Store = @(,@(,$false*$totalLength))*$StoreSize
  $ActiveStore = 0
  $CurrentCombination = ''
  $stack = New-Object 'System.Collections.Stack'
  $stack.Push(($totalLength, $numB, $currentCombination))
  
  while ($stack.Count -gt 0) {
    $totalLength, $numB, $currentCombination = $stack.Pop()
    
    if ($totalLength -eq 0) {
      $store[$ActiveStore] = $currentCombination
      $ActiveStore++
    } else {
      if ($numB -gt 0) {
        $stack.Push((($totalLength - 1), ($numB - 1), ($currentCombination + 'B')))
      }
      if ($totalLength - $numB -gt 0) {
        $stack.Push((($totalLength - 1), $numB, ($currentCombination + 'W')))
      }
    }
  }
  $PuzzleResult = 0
  $Store.ForEach{
    $puzzle_ = $puzzle.ToCharArray()
    for ($i = 0; $i -lt $PuzzleUnknowns.Count; $i++) {
      $puzzle_[$PuzzleUnknowns[$i].Index]=$_[$i]
    }
    if ([regex]::matches($puzzle_ -join'','B+').length -join ',' -eq $SolutionString) {$PuzzleResult++;$Result++}
  }
  $Results += $PuzzleResult
  Write-Host $PuzzleResult
  # Write-Host "$Result after $Puzzle" 
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 9608724 (21 (1,4,1,1,4,10) for testdata)