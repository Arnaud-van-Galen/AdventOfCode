Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo1.txt -ErrorAction Stop
# $Data = Get-Content -Path $PSScriptRoot\DataDemo2.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

[Int64] $Result = 0
$GridWidth = $Data[0].Length
$Movements = @{ [char]'^' = -1*$GridWidth ; [char]'>' = 1 ; [char]'v' = $GridWidth ; [char]'<' = -1 }

for ($y = 0; $y -lt $Data.Count; $y++) {
	if ($Data[$y].EndsWith('#')) { $GridHeight++ } else { $Moves += $Data[$y].Trim() }
}
$MapString = $Data[0..($GridHeight-1)] -join ''
$RobotPosition = [regex]::Matches($MapString, '@').Index
$Map = $MapString.ToCharArray()
# for ($i = 0; $i -lt $GridHeight; $i++) { $Map[($i*$GridWidth)..(($i+1)*$GridWidth-1)] -join '' } # Draw initial Map

foreach ($Move in $Moves.ToCharArray()) {
	$MoveGroup = @($RobotPosition)
	do {
		$NextPosition = $Robotposition + ($MoveGroup.Count) * $Movements[$Move]
		$AtNextPosition = $Map[$NextPosition]
		switch ($AtNextPosition) {
			'#' { continue }
			'O' { $MoveGroup += $NextPosition ; break }
			'.' {
				$MoveGroup += $NextPosition
				for ($i = $MoveGroup.Count-1; $i -gt 0 ; $i--) {
					 $Map[$MoveGroup[$i]] = $Map[$MoveGroup[$i-1]] }
				$Map[$MoveGroup[0]] = [char]'.'
				$RobotPosition = $MoveGroup[1]
				break
			}
			Default  {Write-Host "Alarm, this shouldn't happen" }
		}
	} while ($AtNextPosition -eq 'O')
}
# for ($i = 0; $i -lt $GridHeight; $i++) { $Map[($i*$GridWidth)..(($i+1)*$GridWidth-1)] -join '' } # Draw final Map
foreach ($Box in [regex]::Matches($Map -join '', 'O').Index) {
	$DivRem = [System.Math]::DivRem($Box, $GridWidth)
	$Result += $DivRem.Item1*100+$DivRem.Item2
}

# Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host "Calculated answer: $Result"
Write-Host "Correct answer: 1463512 (2028 for testdata1, 10092 for testdata2)"
Write-Host "To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('C:','/mnt/c').Replace('\','/'))"
Write-Host "To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('/mnt/c','C:').Replace('/','\'))"