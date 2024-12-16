Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$Data = Get-Content -Path $PSScriptRoot\DataDemo3.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\DataDemo2.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

[Int64] $Result = 0
$GridWidth = $Data[0].Length * 2
$Movements = @{ [char]'^' = -1*$GridWidth ; [char]'>' = 1 ; [char]'v' = $GridWidth ; [char]'<' = -1 }

for ($y = 0; $y -lt $Data.Count; $y++) {
	if ($Data[$y].EndsWith('#')) { $GridHeight++ } else { $Moves += $Data[$y].Trim() }
}
$MapString = ($Data[0..($GridHeight-1)] -join '').Replace('#', '##').Replace('O', '[]').Replace('.', '..').Replace('@', '@.')
$Map = $MapString.ToCharArray()
$RobotPosition = [regex]::Matches($MapString, '@').Index
for ($i = 0; $i -lt $GridHeight; $i++) { ($Map[($i*$GridWidth)..(($i+1)*$GridWidth-1)] -join '').Replace('@', "`e[31m@`e[0m") } #; [System.Console]::ReadLine()# Draw initial Map

foreach ($Move in $Moves.ToCharArray()) {
	if ($Move -in ('<','>')) {
		$MoveGroup = @($RobotPosition)
		do {
			$NextPosition = $Robotposition + ($MoveGroup.Count) * $Movements[$Move]
			$AtNextPosition = $Map[$NextPosition]
			switch ($AtNextPosition) {
				'#' { continue }
				'[' { $MoveGroup += $NextPosition ; break }
				']' { $MoveGroup += $NextPosition ; break }
				'.' {
					$MoveGroup += $NextPosition
					for ($i = $MoveGroup.Count-1; $i -gt 0 ; $i--) {
						$Map[$MoveGroup[$i]] = $Map[$MoveGroup[$i-1]]
					}
					$Map[$MoveGroup[0]] = [char]'.'
					$RobotPosition = $MoveGroup[1]
					break
				}
				Default  {Write-Host "Alarm, this shouldn't happen" }
			}
		} while ($AtNextPosition -eq '[' -or $AtNextPosition -eq ']')
	} else {
		$FirstHitPosition = $RobotPosition + $Movements[$Move]
		$AtFirstHitPosition = $Map[$FirstHitPosition]
		switch ($AtFirstHitPosition) {
			'#' { continue }
			'.' { 
				$Map[$RobotPosition] = [char]'.'
				$RobotPosition = $FirstHitPosition
				$Map[$RobotPosition] = [char]'@'
				continue
			}
			Default {
				$RowCount = 0
				$ToCheckInRow = @(,@($RobotPosition))
				do {
					$AnyWall = $false
					$EmptyCountNeeded = $ToCheckInRow[$RowCount].Count
					$AdditionalBoxFields = @()
					$ToCheckInRow[$RowCount].foreach{
						$HitPosition = $_ + $Movements[$Move]
						$AtHitPosition = $Map[$HitPosition]
						switch ($AtHitPosition) {
							'#' { $AnyWall = $true ; break }
							'.' { $EmptyCountNeeded-- ; break }
							'[' { $AdditionalBoxFields += $HitPosition ; $AdditionalBoxFields += $HitPosition + 1 ; break }
							']' { $AdditionalBoxFields += $HitPosition ; $AdditionalBoxFields += $HitPosition - 1 ; break }
						}
					}
					$RowCount++
					$ToCheckInRow += ,($AdditionalBoxFields | Sort-Object -Unique)
				} until ($AnyWall -or $EmptyCountNeeded -eq 0)
				if ($EmptyCountNeeded -eq 0) { $MovedBoxCount++
					for ($i = $ToCheckInRow.Count - 1; $i -ge 0; $i--) {
						for ($j = 0; $j -lt $ToCheckInRow[$i].Count; $j++) {
							$Map[$ToCheckInRow[$i][$j] + $Movements[$Move]] = $Map[$ToCheckInRow[$i][$j]]
							$Map[$ToCheckInRow[$i][$j]] = [char]'.'
						}
					}
					$Map[$RobotPosition] = [char]'.'
					$RobotPosition = $RobotPosition + $Movements[$Move]
				}
			}
		}
	}
}
for ($i = 0; $i -lt $GridHeight; $i++) { ($Map[($i*$GridWidth)..(($i+1)*$GridWidth-1)] -join '').Replace('@', "`e[31m@`e[0m") } #; [System.Console]::ReadLine()# Draw final Map
foreach ($Box in [regex]::Matches($Map -join '', '\[').Index) {
	$DivRem = [System.Math]::DivRem($Box, $GridWidth)
	$Result += $DivRem.Item1*100+$DivRem.Item2
}

# Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host "Calculated answer: $Result"
Write-Host "Correct answer: 1486520 (9021 for testdata2)"
Write-Host "To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('C:','/mnt/c').Replace('\','/'))"
Write-Host "To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('/mnt/c','C:').Replace('/','\'))"