Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
Set-StrictMode -Version Latest
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

[Int64] $Result = 0

$NumPad = @{ 
	'7' = @{ '8' = '>' ; '4' = 'v' }
	'8' = @{ '9' = '>' ; '5' = 'v' ; '7' = '<' }
	'9' = @{ '6' = 'v' ; '8' = '<' }
	'4' = @{ '7' = '^' ; '5' = '>' ; '1' = 'v' }
	'5' = @{ '8' = '^' ; '6' = '>' ; '2' = 'v' ; '4' = '<' }
	'6' = @{ '9' = '^' ; '3' = 'v' ; '5' = '<' }
	'1' = @{ '4' = '^' ; '2' = '>' }
	'2' = @{ '5' = '^' ; '3' = '>' ; '0' = 'v' ; '1' = '<' }
	'3' = @{ '6' = '^' ; 'A' = 'v' ; '2' = '<' }
	'0' = @{ '2' = '^' ; 'A' = '>' }
	'A' = @{ '3' = '^' ; '0' = '<' }
}
$DirPad = @{
	'^' = @{ 'A' = '>' ; 'v' = 'v' }
	'A' = @{ '>' = 'v' ; '^' = '<' }
	'<' = @{ 'v' = '>' }
	'v' = @{ '^' = '^' ; '>' = '>' ; '<' = '<' }
	'>' = @{ 'A' = '^' ; 'v' = '<' }
}

function GraphSearcher ([string]$Start, [string]$Target, [hashtable]$Graph) {
	# $FullPaths = @{}
	$SimplifiedPaths = @()
	$MinLength = [int]::MaxValue
	$BFS = [System.Collections.Queue]::new()
	$BFS.Enqueue(($Start, @($Start), @($null))) # Keep track of Position, Path and the moves that are needed on the next pad
	while ($BFS.Count -gt 0) {
		$Position, $Path, $NeededOnPad = $BFS.Dequeue()
		if ($Position -eq $Target) {
			if ($Path.Count -gt $MinLength) { break }
			$MinLength = $Path.Count
			# $FullPaths[$Path] = $NeededOnPad
			$SimplifiedPaths += ($NeededOnPad -join '') + "A"
		} else {
			if ($Path.Count -gt $MinLength) { break }
			foreach ($NextPosition in $Graph[$Position].Keys) {
				if ($Path -notcontains $NextPosition) {
					$NextPath = $Path + $NextPosition
					$NextNeededOnPad = $NeededOnPad + $Graph[$Position][$NextPosition]
					$BFS.Enqueue(($NextPosition, $NextPath, $NextNeededOnPad))
				}
			}
		}
	}
	# return $FullPaths
	return $SimplifiedPaths
}
function ArrayUnpacker ([array]$NestedArray) {
	for ($i = 1; $i -lt $NestedArray.Count; $i++) {
		if($NestedArray[$i].Count -gt 1) {$NestedArray[0] *= $NestedArray[$i].Count}
		$GroupCount = $NestedArray[0].Count/$NestedArray[$i].Count
		for ($j = 0; $j -lt $NestedArray[0].Count; $j++) {
			$NestedArray[0][$j] += $NestedArray[$i][[int]::CreateTruncating($j/$GroupCount)]
		}
	}
	return $NestedArray[0]
}

function StepCalculator([string]$From, [string]$To) {
	$DataLine = $To
	$NumPadPaths = [array]::CreateInstance([array], $DataLine.Length)
	$DataLine = $From + $DataLine
	for ($i = 0; $i -lt $DataLine.Length-1; $i++) {
		$NumPadPaths[$i] = GraphSearcher -Start $DataLine[$i] -Target $DataLine[$i+1] -Graph $NumPad
	}
	$NumPadPaths = ArrayUnpacker -NestedArray $NumPadPaths
	# Write-Host $DataLine
	# Write-Host ($NumPadPaths.ForEach{$_.Length} | Measure-Object -Minimum).Minimum

	$AllDirPad1Paths = @()
	foreach ($NumPadPath in $NumPadPaths) {
		$DirPad1Paths = [array]::CreateInstance([array], $NumPadPath.Length)
		$NumPadPath = "A" + $NumPadPath
		for ($i = 0; $i -lt $NumPadPath.Length-1; $i++) {
			$DirPad1Paths[$i] = GraphSearcher -Start $NumPadPath[$i] -Target $NumPadPath[$i+1] -Graph $DirPad
		}
		$DirPad1Paths = ArrayUnpacker -NestedArray $DirPad1Paths
		$AllDirPad1Paths += $DirPad1Paths
		# Write-Host $NumPadPath
	}
	# Write-Host ($AllDirPad1Paths.ForEach{$_.Length} | Measure-Object -Minimum).Minimum

	$AllDirPad2Paths = @()
	foreach ($AllDirPad1Path in $AllDirPad1Paths) {
		# $AllDirPad1Path = 'v<<A>>^A<A>AvA<^AA>A<vAAA>^A'
		$DirPad2Paths = [array]::CreateInstance([array], $AllDirPad1Path.Length)
		$AllDirPad1Path = "A" + $AllDirPad1Path
		for ($i = 0; $i -lt $AllDirPad1Path.Length-1; $i++) {
			$DirPad2Paths[$i] = GraphSearcher -Start $AllDirPad1Path[$i] -Target $AllDirPad1Path[$i+1] -Graph $DirPad
		}
		$DirPad2Paths = ArrayUnpacker -NestedArray $DirPad2Paths
		$AllDirPad2Paths += $DirPad2Paths
		# Write-Host $AllDirPad1Path
	}
	# Write-Host (($AllDirPad2Paths.ForEach{$_.Length} | Measure-Object -Minimum).Minimum)

	return (($AllDirPad2Paths.ForEach{$_.Length} | Measure-Object -Minimum).Minimum)
}

foreach ($DataLine in $Data) {
	$MinLength = 0
	$NumPadPaths = [array]::CreateInstance([array], $DataLine.Length)
	$DataLine = 'A' + $DataLine
	for ($i = 0; $i -lt $DataLine.Length-1; $i++) {
		$NumPadPaths[$i] = GraphSearcher -Start $DataLine[$i] -Target $DataLine[$i+1] -Graph $NumPad
		$MinLength += StepCalculator -From $DataLine[$i] -To $DataLine[$i+1]
	}
	$NumPadPaths = ArrayUnpacker -NestedArray $NumPadPaths
	$NumPart = [int]$Dataline.Replace('A','')
	$Result += $MinLength * $NumPart
}

# Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host "Calculated answer: $Result"
Write-Host "Correct answer: 105458 (126384 for testdata)"
Write-Host "To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('C:','/mnt/c').Replace('\','/'))"
Write-Host "To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('/mnt/c','C:').Replace('/','\'))"