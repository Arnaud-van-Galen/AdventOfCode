Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo1.txt -ErrorAction Stop
# $Data = Get-Content -Path $PSScriptRoot\DataDemo2.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$SearchCounter=0
[Int64] $Result = [int]::MaxValue
$GridHeight = $Data.Count
$GridWidth = $Data[0].Length
$Directions = (-1*$GridWidth), 1, $GridWidth, -1
$TurnCost = 1,1001,2001,1001
$MapString = $Data -join ''
$StartIndex = [regex]::Matches($MapString, 'S').Index
$EndIndex = [regex]::Matches($MapString, 'E').Index
$Progress = @($null)*$GridHeight*$GridWidth
for ($p = 0; $p -lt $Progress.Count; $p++) {$Progress[$p] = ,([int]::MaxValue)*$Directions.Count}

$MazeSearcher = [System.Collections.Stack]::new() # Keep track of Position, Direction and Score
$MazeSearcher.Push(($StartIndex, 1, 0))
While ($MazeSearcher.Count -gt 0) {
	$SearchCounter++
	$Position, $Direction, $Score = $MazeSearcher.Pop()
	if ($Score -lt $Progress[$Position][$Direction] -and $Score -lt (($Progress[$Position] | Measure-Object -Minimum).Minimum + 1000)) {
		$Progress[$Position][$Direction] = $Score
		if ($Position -eq $EndIndex) {
			$Result = $Score ; Write-Host $Score
		} else {
			foreach ($i in 3,1,0) {
				$NextDirection = ($Direction + $i) % $Directions.Count
				$NextScore = $Score + $TurnCost[$i]
				$NextPosition = $Position + $Directions[$NextDirection]
				if ($MapString[$NextPosition] -ne '#' -and $NextScore -lt $Result) { $MazeSearcher.Push(($NextPosition, $NextDirection, $NextScore))}
			}
		}
	}
}

# Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host "Calculated answer: $Result with $SearchCounter searches"
Write-Host "Correct answer: 83444 (7036 for testdata1, 11048 for testdata2)"
Write-Host "To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('C:','/mnt/c').Replace('\','/'))"
Write-Host "To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('/mnt/c','C:').Replace('/','\'))"