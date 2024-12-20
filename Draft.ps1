Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

class MyClass {
    $MyClassProperty = "Het werkt!"
}
$x = [MyClass]::new()
$x.Count
$x.GetType()
$x.MyClassProperty

$y = [MyClass[]]::new(2)
$y.Count
$y.GetType()
$y[0] = [MyClass]::new()
$y[0].MyClassProperty

$a = "abcde"
$b = $a.ToCharArray()
[array]::Reverse($b) # $b is now the reversed characterarray ("e", "d", "c", "b", "a") and can be changed back to "edcba" with -join $b

function Rotate-StringArray { param ($array)
  $array = $array.Clone()
  [Array]::Reverse($array)
  $array = 
    for ($i = 0; $i -lt $array[0].Length; $i++) {
      -join $array.ForEach{$_[$i]}
    }
  return $array
}

$array = @(1,2,3)
$array_ref = $array
$array_val = $array.ForEach{ $_ } # https://www.powershelladmin.com/wiki/Deep_copying_arrays_and_objects_in_PowerShell.php
$array[0] = 11
$array_ref[1] = 12
$array_val[2] = 13
Write-Output $array, $array_ref, $array_val -NoEnumerate

$strings=@"
123
456
"@.split()
$intarray = [int32[]]::new($strings.count)
# Doesn't work yet. Work in Progress / ToDo. Should become (1,2,3),(4,5,6)
$strings.foreach{$_.ToCharArray().foreach{$intarray[$foreach]=[int]$_.tostring()}}

$data = "[1,[2,[3,[4,[5,6,7]]]],8,9]"
$datePattern = [Regex]::new("\[*\]")
$matches = $datePattern.Matches($data)
$matches.Value

#MazeSolver (with walls around it)
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