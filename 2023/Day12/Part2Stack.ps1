Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int]$Result = 0
$Cache = @{}

[string]$PuzzlePiece = 'UUUWUUU'
[string]$SolutionStringPiece = '1,2'
# [string]$PuzzlePiece = 'UUUUUWWUUUUUBUUUUUUUUUUWWUUUUUBUUUUUUUUUUWWUUUUUBUUUU'
# [string]$SolutionStringPiece = '3,3,2,3,3,2,3,3,2'
# [string]$PuzzlePiece = 'UUBWWUUUWUUUUBWWUUUWU'
# [string]$SolutionStringPiece = '2,1,2,1' # 4,32,256

$Stack = [System.Collections.Stack]::New()
$Stack.Push(($PuzzlePiece, $SolutionStringPiece.Split(','), ([int]$ResultPiece = 0)))
while ($Stack.Count -gt 0) {
	[string]$PuzzlePiece, [int[]]$SolutionArrayPiece, [int]$currentResultPiece = $Stack.Pop()
	# If there are no more blacks in the solution that is only okay if there are no more blacks in the puzzle as well
	if (!$SolutionArrayPiece) {
		if ($PuzzlePiece -notmatch 'B') {$currentResultPiece++}
	} else {
		if ($Cache["$PuzzlePiece,$($SolutionArrayPiece -join ',')"]) {
			$currentResultPiece=$Cache["$PuzzlePiece,$($SolutionArrayPiece -join ',')"]
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
						$Cache["$PuzzlePieceNext,$($SolutionArrayPieceNext -join ',')"] = $currentResultPiece
						$Stack.Push(($PuzzlePieceNext, $SolutionArrayPieceNext, $currentResultPiece))
					}
				}
			}
		}
	}
	$Result += $currentResultPiece
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 6958 (525152 (1,16384,1,16,2500,506250) for testdata)