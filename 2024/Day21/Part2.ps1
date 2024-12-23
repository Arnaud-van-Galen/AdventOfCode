Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
Set-StrictMode -Version Latest
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$Result = 0
$DirPads = 2
$ThanksForHelpingMeRememberGio = @{} # cache


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
			$SimplifiedPaths += ($NeededOnPad -join '') + 'A'
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

function NumPadCalculator([array]$NodesToVisit) {
	$Paths = [array]::CreateInstance([array], $NodesToVisit.Count)
	$NodesToVisit = ,'A' + $NodesToVisit
	for ($i = 1; $i -lt $NodesToVisit.Length; $i++) {
		$Paths[$i-1] = GraphSearcher -Start $NodesToVisit[$i-1] -Target $NodesToVisit[$i] -Graph $NumPad
	}
	return $Paths
}

function RecursivelyFind { param ( [string]$Design )
	if ($ThanksForHelpingMeRememberGio.ContainsKey($Design)) { return $ThanksForHelpingMeRememberGio[$Design] } # Try to retrieve from cache
	if ($Design -eq "") { return 1 }
	$Count = 0

	foreach ($Towel in $Towels) {	if ($Design.StartsWith($Towel)) { $Count += RecursivelyFind($Design.Substring($Towel.Length)) } }

	$ThanksForHelpingMeRememberGio[$Design] = $Count # Add to cache
	return $Count
}


function DirPadCalculator([string[]]$InputSequences) {
	$AllPaths = @()
	foreach ($NodesToVisit in $InputSequences) {
		$Paths = [array]::CreateInstance([string], $NodesToVisit.Length)
		$NodesToVisit = 'A' + $NodesToVisit
		for ($i = 1; $i -lt $NodesToVisit.Length; $i++) {
			$Paths[$i-1] = GraphSearcher -Start $NodesToVisit[$i-1] -Target $NodesToVisit[$i] -Graph $DirPad
		}
		$Paths = ArrayUnpacker -NestedArray $Paths
		$AllPaths += $Paths
	}
	return $AllPaths
}

foreach ($DataLine in $Data[0]) {
	$NumPadPaths = NumPadCalculator -NodesToVisit ([string[]]$DataLine.ToCharArray())
	DirPadCalculator -InputSequences $NumPadPaths[0]
	# $MinLength = StepCalculator -NodesToVisit (,'A' + [string[]]$DataLine.ToCharArray()) -Graph $NumPad
	# $NumPart = [int]$Dataline.Replace('A','')
	# $Result += $MinLength * $NumPart
}

Get-MyVariables
Write-Host 'Time for calculating:', $stopwatch.Elapsed.TotalSeconds
Write-Host 'Calculated answer:', $Result
Write-Host 'Correct answer: ??? (XXX for testdata)'
Write-Host 'To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('C:','/mnt/c').Replace('\','/')
Write-Host 'To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('/mnt/c','C:').Replace('/','\')