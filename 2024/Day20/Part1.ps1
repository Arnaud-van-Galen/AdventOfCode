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

$Cheats = @{}
for ($Position = 0; $Position -lt $Progress.Count; $Position++) {
	foreach ($d in 0..($Directions.Count-1)) {
		$NextPosition = $Position + $Directions[$d]*2
		if ($NextPosition -lt 0 -or $NextPosition -ge $Progress.Count) { continue } # Going offgrid usually results in an encounter with a wall but otherwise we should just stop
		if ($Progress[$NextPosition] -eq [int]::MaxValue) { continue } # Cannot jump into a wall
		$CheatInfluence = $Progress[$NextPosition]-$Progress[$Position]-2
		if ($CheatInfluence -ge 100) {$Cheats[$CheatInfluence]++}
	}
}
$Result = ($Cheats.Values | Measure-Object -Sum).Sum
# ($Cheats.GetEnumerator() | Sort-Object Name).foreach{"$($_.Name), $($_.Value)"}

# Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host "Calculated answer: $Result"
Write-Host "Correct answer: 1406 (44 for testdata with CheatInfluence -ge 1)"
Write-Host "To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('C:','/mnt/c').Replace('\','/'))"
Write-Host "To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('/mnt/c','C:').Replace('/','\'))"