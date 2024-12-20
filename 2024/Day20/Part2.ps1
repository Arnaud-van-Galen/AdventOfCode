Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
Set-StrictMode -Version Latest
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$SearchCounter=0
[Int64] $Result = [int]::MaxValue
$GridHeight = $Data.Count
$GridWidth = $Data[0].Length
$Directions = (-1*$GridWidth), 1, $GridWidth, -1
$MapString = $Data -join ''
$StartIndex = [regex]::Matches($MapString, 'S').Index
$EndIndex = [regex]::Matches($MapString, 'E').Index
$Progress = @($null)*$GridHeight*$GridWidth
for ($p = 0; $p -lt $Progress.Count; $p++) {$Progress[$p] = [int]::MaxValue}
$CheatAllowance = 20
$CheatCutoff = 100 # 50 for test, 100 for real

$MazeSearcher = [System.Collections.Stack]::new() # Keep track of Position and Score
$MazeSearcher.Push(($StartIndex, 0))
While ($MazeSearcher.Count -gt 0) {
	$SearchCounter++
	$Position, $Score = $MazeSearcher.Pop()
	if ($Score -lt $Progress[$Position]) {
		$Progress[$Position] = $Score
		if ($Position -eq $EndIndex) {
			$Result = $Score
		} else {
			foreach ($i in 0..($Directions.Count-1)) {
				$NextPosition = $Position + $Directions[$i]
				$NextScore = $Score + 1
				if ($MapString[$NextPosition] -ne '#' -and $NextScore -lt $Result) { $MazeSearcher.Push(($NextPosition, $NextScore))}
			}
		}
	}
}

# Draw for clarity
<#
$DrawLength =  ([string]($Progress.Where{$_ -ne [int]::MaxValue} | Measure-Object -Maximum).Maximum).length+1
$BiggerMap = ""
for ($i = 0; $i -lt $MapString.Length; $i++) {
	if ($Progress[$i] -ne [int]::MaxValue) { $BiggerMap += $Progress[$i].ToString().PadLeft($DrawLength)}
	else { $BiggerMap += $MapString[$i].ToString()*$DrawLength}
}
$Map = $BiggerMap.ToCharArray()
for ($d = 0; $d -lt $GridHeight; $d++) { ($Map[($d*$GridWidth*$DrawLength)..(($d+1)*$GridWidth*$DrawLength-1)] -join '').Replace('O', "`e[31mO`e[0m") }
#>

#Convert $Progress into $Positions with XY
$Positions = @{}
for ($i = 0; $i -lt $Progress.Count; $i++) {
	if ($Progress[$i] -ne [int]::MaxValue) {
		$DivRem = [System.Math]::DivRem($i,$GridWidth)
		$Positions[$Progress[$i]] = @{ Y = $DivRem.Item1; X = $DivRem.Item2 }
	}
}
# Loop from all positions to positions that are more than 50/100 further away and check if they are within the 20 cheatrange
$Cheats = @{}
for ($Position = 0; $Position -lt $Positions.Count - $CheatCutoff; $Position++) {
	# Write-Host "Progress: $Position from $($Positions.Count)"
	for ($NextPosition = $CheatCutoff; $NextPosition -lt $Positions.Count; $NextPosition++) {
		$Distance = [int]::Abs($Positions[$Position].Y-$Positions[$NextPosition].Y) + [int]::Abs($Positions[$Position].X-$Positions[$NextPosition].X)
		if ($Distance -gt $CheatAllowance) { continue } # Too far, can't reach
		$CheatInfluence = $NextPosition - $Position - $Distance
		if ($CheatCutoff -le $CheatInfluence) {$Cheats[$CheatInfluence]++}
	}
}

$Result = ($Cheats.Values | Measure-Object -Sum).Sum
# ($Cheats.GetEnumerator() | Sort-Object Name).foreach{"There are $($_.Value) cheats that save $($_.Name) picoseconds"}

# Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host "Calculated answer: $Result"
Write-Host "Correct answer: 1006101 (285 for testdata with CheatCutoff = 50)"
Write-Host "To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('C:','/mnt/c').Replace('\','/'))"
Write-Host "To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('/mnt/c','C:').Replace('/','\'))"