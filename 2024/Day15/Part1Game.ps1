function LoadLevel { param ([int]$Level)
	Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
	[System.Console]::Clear()
	switch ($Level) {
		2 { $Data = Get-Content -Path $PSScriptRoot\DataDemo2.txt -ErrorAction Stop }
		3 { $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop }
		Default { $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop }
	}	
	$Global:GridWidth = $Data[0].Length
	$Global:GridHeight = 0 ; for ($y = 0; $y -lt $Data.Count; $y++) { if ($Data[$y].EndsWith('#')) { $Global:GridHeight++ } }
	$Global:Movements = @{ 'U' = -1*$GridWidth ; 'R' = 1 ; 'D' = $GridWidth ; 'L' = -1 }
	$MapString = $Data[0..($GridHeight-1)] -join ''
	$Global:RobotPosition = [regex]::Matches($MapString, '@').Index
	$Global:Map = $MapString.ToCharArray()
}

LoadLevel -Level 3

Write-Host "Press arrow keys to move around, 1 2 or 3 to change level or q to stop."
while ($PressedKey.Key -ne 'q') {
	[System.Console]::Clear()
	for ($i = 0; $i -lt $GridHeight; $i++) { ($Map[($i*$GridWidth)..(($i+1)*$GridWidth-1)] -join '').Replace('@', "`e[31m@`e[0m") }
	$PressedKey = [System.Console]::ReadKey($true)
	switch ($PressedKey.Key) {
		'UpArrow' { $Move = 'U' }
		'RightArrow' { $Move = 'R' }
		'DownArrow' { $Move = 'D' }
		'LeftArrow' { $Move = 'L' }
		{$_ -in @('D1','D2','D3')} { write-host "loading lever $_"; LoadLevel -Level $_}
		'q' { break }
		default { Write-Host "You pressed $($PressedKey.KeyChar)." }
	}
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