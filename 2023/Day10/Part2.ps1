Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0
$Moves = @{
  'U' = @(0,-1)
  'R' = @(1,0)
  'D' = @(0,1)
  'L' = @(-1,0)
}
$Tiles = @{
  # Every pipe/bend has 2 possible directions that change into new directions 
  '|' = @{'U'='U';'D'='D'} # a vertical pipe connecting north and south.
  '-' = @{'R'='R';'L'='L'} # a horizontal pipe connecting east and west.
  'L' = @{'D'='R';'L'='U'} # a 90-degree bend connecting north and east.
  'J' = @{'D'='L';'R'='U'} # a 90-degree bend connecting north and west.
  '7' = @{'U'='L';'R'='D'} # a 90-degree bend connecting south and west.
  'F' = @{'U'='R';'L'='D'} # a 90-degree bend connecting south and east.
  '.' = @{} # ground; there is no pipe in this tile.
  'S' = @{} # the starting position of the animal; there is a pipe on this tile, but your sketch doesn't show what shape the pipe has. 
}
$Fillings = @{
  0 = @{'O'='O';'I'='I'}
  1 = @{'O'='I';'I'='O'}
}

# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo3.txt -ErrorAction Stop
# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo4.txt -ErrorAction Stop
# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo5.txt -ErrorAction Stop
# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo6.txt -ErrorAction Stop
[string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
$GridWidth = $Data[0].Length
$GridHeight = $Data.Length
$SIndex = ($Data -join '').IndexOf('S')
$StartPosition = [PSCustomObject]@{X = $SIndex % $GridWidth;Y = [int][System.Math]::Floor($SIndex / $GridWidth)}
$NewPosition = [PSCustomObject]@{X = 0;Y = 0}

$AllowedMovesFromStart = $Moves.Keys.ForEach{
  $NewPosition.X = $StartPosition.X + $Moves[$_][0]
  $NewPosition.Y = $StartPosition.Y + $Moves[$_][1]
  if ($NewPosition.X -ge 0 -and $NewPosition.X -lt $GridWidth -and $NewPosition.Y -ge 0 -and $NewPosition.Y -lt $GridHeight) {
    $NewPositionTile = [string]$Data[$NewPosition.Y][$NewPosition.X]
    if ($Tiles[$NewPositionTile][$_].Count -gt 0) {$_}
  }
}
$Move = $AllowedMovesFromStart[0]
$StartTile = $Tiles.Keys.Where{(Compare-Object $Tiles[$_].Values.ForEach{$_} $AllowedMovesFromStart).Count -eq 0}[0]

$PathArray = (' '*$GridHeight*$GridWidth).ToCharArray()
$NewPosition.X, $NewPosition.Y = $StartPosition.X, $StartPosition.Y 
$MoveCount = 0
do {
  $PathArray[$NewPosition.Y*$GridWidth+$NewPosition.X]=[string]$Data[$NewPosition.Y][$NewPosition.X]
  $NewPosition.X, $NewPosition.Y = ($NewPosition.X + $Moves[$Move][0]), ($NewPosition.Y + $Moves[$Move][1])
  $NewPositionTile = [string]$Data[$NewPosition.Y][$NewPosition.X]
  $Move = $Tiles[$NewPositionTile][$Move]
  $MoveCount++
} until ($NewPosition.X -eq $StartPosition.X -and $NewPosition.Y -eq $StartPosition.Y)
$PathArray[$StartPosition.Y*$GridWidth+$StartPosition.X] = $StartTile

$ZeroFillLoops = [int][Math]::Ceiling(([Math]::Min($GridWidth, $GridHeight)/2))
for ($z = 0; $z -lt $ZeroFillLoops; $z++) {
  for ($i = $z*$GridWidth+$z; $i -lt $PathArray.Count-$z-$z*$GridWidth; $i++) {
    if ($PathArray[$i] -eq ' ') {
      if (($i -in @(($z*$GridWidth+$z)..(($z+1)*$GridWidth-($z+1)))) `
        -or ($i % $GridWidth -eq 0+$z) `
        -or ($i % $GridWidth -eq $GridWidth-1-$z) `
        -or ($i -in @((($GridHeight-1-$z)*$GridWidth+$z)..((($GridHeight-$z)*$GridWidth)-$z)))
      ) {
        if ($z -eq 0) {
          $PathArray[$i] = 'O'
        } else {
          if ($PathArray[$i-1] -eq 'O' -or $PathArray[$i+1] -eq 'O' -or $PathArray[$i-$GridWidth] -eq 'O' -or $PathArray[$i+$GridWidth] -eq 'O') {
            $PathArray[$i] = 'O'
          }
        }
      }
    } 
  }
}
$Path = for ($i = 0; $i -lt $GridHeight; $i++) {
  $PathArray[($i * $GridWidth)..($i * $GridWidth + $GridWidth-1)] -join ''
}

while ($Spaces = $path | select-String ' ' -AllMatches) {
  $spaces.LineNumber.ForEach{
    $y = $_-1
    $LineSpaces = $Path[$y] | Select-String ' ' -AllMatches
    $LineSpaces.Matches.ForEach{
      $x = $_.Index
      if ($Path[$y][$x-1] -eq 'O' -or $Path[$y][$x+1] -eq 'O' -or $Path[$y-1][$x] -eq 'O' -or $Path[$y+1][$x] -eq 'O') {
        $Path[$y] = $Path[$y].Remove($x,1).Insert($x,'O')
      } elseif ($Path[$y][$x-1] -eq 'I' -or $Path[$y][$x+1] -eq 'I' -or $Path[$y-1][$x] -eq 'I' -or $Path[$y+1][$x] -eq 'I') {
        $Path[$y] = $Path[$y].Remove($x,1).Insert($x,'I')
      } else {
        $CurrentMatches = $null
        $HasBeenAssigned = $false
        if (!$HasBeenAssigned) {
          $CheckLeft = $Path[$y][($x-1)..0] + 'O' -join '' -replace '-+', ''
          $CheckLeftNextNonPath = [regex]::Matches($CheckLeft,'[|\-LJ7F]+(?:O|I| )')[0].Value
          if (!$CheckLeftNextNonPath.EndsWith(' ')) {$CurrentMatches = @([Regex]::Matches($CheckLeftNextNonPath,'7L|JF|[|LJ7F]'))}
          if ($CurrentMatches) {
            $Path[$y] = $Path[$y].Remove($x,1).Insert($x,$Fillings[$CurrentMatches.Count % 2][$CheckLeftNextNonPath[-1].ToString()])
            $HasBeenAssigned = $true
          }
        }
        
        if (!$HasBeenAssigned) {
          $CheckRight = $Path[$y][($x+1)..($GridWidth-1)] + 'O' -join '' -replace '-+', ''
          $CheckRightNextNonPath = [regex]::Matches($CheckRight,'[|\-LJ7F]+(?:O|I| )')[0].Value
          if (!$CheckRightNextNonPath.EndsWith(' ')) { $CurrentMatches = @([Regex]::Matches($CheckRightNextNonPath,'L7|FJ|[|LJ7F]')) }
          if ($CurrentMatches) {
            $Path[$y] = $Path[$y].Remove($x,1).Insert($x,$Fillings[$CurrentMatches.Count % 2][$CheckRightNextNonPath[-1].ToString()])
            $HasBeenAssigned = $true
          }
        }

        if (!$HasBeenAssigned) {
          $CheckUp = $Path[($y-1)..0].ForEach{$_[$x]} + 'O' -join '' -replace '\|+', ''
          $CheckUpNextNonPath = [regex]::Matches($CheckUp,'[|\-LJ7F]+(?:O|I| )')[0].Value
          if (!$CheckUpNextNonPath.EndsWith(' ')) { $CurrentMatches = @([Regex]::Matches($CheckUpNextNonPath,'7L|FJ|[\-LJ7F]')) }
          if ($CurrentMatches) {
            $Path[$y] = $Path[$y].Remove($x,1).Insert($x,$Fillings[$CurrentMatches.Count % 2][$CheckUpNextNonPath[-1].ToString()])
            $HasBeenAssigned = $true
          }
        }
        
        if (!$HasBeenAssigned) {
          $CheckDown = $Path[($y+1)..($GridHeight-1)].ForEach{$_[$x]} + 'O' -join '' -replace '\|+', ''
          $CheckDownNextNonPath = [regex]::Matches($CheckDown,'[|\-LJ7F]+(?:O|I| )')[0].Value
          if (!$CheckDownNextNonPath.EndsWith(' ')) { $CurrentMatches = @([Regex]::Matches($CheckDownNextNonPath,'L7|JF|[\-LJ7F]')) }
          if ($CurrentMatches) {
            $Path[$y] = $Path[$y].Remove($x,1).Insert($x,$Fillings[$CurrentMatches.Count % 2][$CheckDownNextNonPath[-1].ToString()])
            $HasBeenAssigned = $true
          }
        }
      }
    }
  }
}

$Result = ($path | select-String 'I' -AllMatches).Matches.count

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = Between 380 and 838 (4, 4, 8 and 10 for testdata)