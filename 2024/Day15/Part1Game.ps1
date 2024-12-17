function LoadLevel { param ([int]$Level)
	# Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
	[System.Console]::Clear()
	switch ($Level) {
		2 { $Data = Get-Content -Path $PSScriptRoot\DataDemo2.txt -ErrorAction Stop ; break }
		3 { $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop ; break }
		Default { $Data = Get-Content -Path $PSScriptRoot\DataDemo1.txt -ErrorAction Stop }
	}	
	$Global:GridWidth = $Data[0].Length
	$Global:GridHeight = 0 ; for ($y = 0; $y -lt $Data.Count; $y++) { if ($Data[$y].EndsWith('#')) { $GridHeight++ } }
	$Global:Movements = @{ 'U' = -1*$GridWidth ; 'R' = 1 ; 'D' = $GridWidth ; 'L' = -1 }
	$MapString = $Data[0..($GridHeight-1)] -join ''
	$Global:RobotPosition = [regex]::Matches($MapString, '@').Index
	$Global:Map = $MapString.ToCharArray()
}

LoadLevel

while ($true) {
	for ($i = 0; $i -lt $GridHeight; $i++) { ($Map[($i*$GridWidth)..(($i+1)*$GridWidth-1)] -join '').Replace('@', "`e[31m@`e[0m") }
	$Move = Read-Host -Prompt "What is your command? Choose U R D L to navigate, 1 2 3 to change level and something else to stop"
	if ($Move -in (1,2,3)) { LoadLevel -Level $Move ; continue }
	elseif ($Move -notin $Movements.Keys) {break}	
	$MoveGroup = @($RobotPosition)
	do {
		$NextPosition = $Robotposition + ($MoveGroup.Count) * $Movements[$Move]
		$AtNextPosition = $Map[$NextPosition]
		switch ($AtNextPosition) {
			'#' { continue }
			'O' { $MoveGroup += $NextPosition ; continue }
			'.' {
				$MoveGroup += $NextPosition
				for ($i = $MoveGroup.Count-1; $i -gt 0 ; $i--) {
					 $Map[$MoveGroup[$i]] = $Map[$MoveGroup[$i-1]] }
				$Map[$MoveGroup[0]] = [char]'.'
				$RobotPosition = $MoveGroup[1]
				break
			}
		}
	} while ($AtNextPosition -eq 'O')
}