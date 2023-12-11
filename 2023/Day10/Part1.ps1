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

# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo2.txt -ErrorAction Stop
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

$NewPosition.X, $NewPosition.Y = $StartPosition.X, $StartPosition.Y 
$MoveCount = 0
do {
  $NewPosition.X, $NewPosition.Y = ($NewPosition.X + $Moves[$Move][0]), ($NewPosition.Y + $Moves[$Move][1])
  $NewPositionTile = [string]$Data[$NewPosition.Y][$NewPosition.X]
  $Move = $Tiles[$NewPositionTile][$Move]
  $MoveCount++
  # Write-Host $NewPosition.X, $NewPosition.Y, $NewPositionTile,$Move, $MoveCount
} until ($NewPosition.X -eq $StartPosition.X -and $NewPosition.Y -eq $StartPosition.Y)
$Result = $MoveCount / 2

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 6754 (4 and 8 for testdata)