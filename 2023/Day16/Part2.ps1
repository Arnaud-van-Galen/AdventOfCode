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
  # Every mirror has 4 possible directions that change into new direction(s)
  '|' = @{'U'='U';'R'=@('U','D');'D'='D';'L'=@('U','D')}
  '-' = @{'U'=@('L','R');'R'='R';'D'=@('L','R');'L'='L'}
  '\' = @{'U'='L';'R'='D';'D'='R';'L'='U'}
  '/' = @{'U'='R';'R'='U';'D'='L';'L'='D'}
  '.' = @{'U'='U';'R'='R';'D'='D';'L'='L'}
}
$MaxEnergized = 0

# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
$GridWidth = $Data[0].Length
$GridHeight = $Data.Length

$stack = [System.Collections.Stack]::new()

$StartMoves = @()
$StartMoves += @(0..($GridWidth-1)).ForEach{, @($_, ($GridHeight-1), 'U')}
$StartMoves += @(0..($GridHeight-1)).ForEach{, @(0, $_, 'R')}
$StartMoves += @(0..($GridWidth-1)).ForEach{, @($_, 0, 'D')}
$StartMoves += @(0..($GridHeight-1)).ForEach{, @(($GridWidth-1), $_, 'L')}
foreach ($StartMove in $StartMoves) {
    $Energized = @{}
    $stack.Push($StartMove)
    
    while ($stack.Count -gt 0) {
        $X, $Y, $Move = $stack.Pop()
        $Energized["$X,$Y,$Move"] = "$X,$Y"
        $TileMoves = $Tiles[$Data[$Y][$X].ToString()][$Move]
        $TileMoves.ForEach{
            $NewX = $X + $Moves[$_][0]
            $NewY = $Y + $Moves[$_][1]
            if ($NewX -ge 0 -and $NewX -lt $GridWidth -and $NewY -ge 0 -and $NewY -lt $GridHeight -and !$Energized["$NewX,$NewY,$_"]) {
                $stack.Push(@($NewX,$NewY,$_))
            }
        }
    }
    $MaxEnergized = [System.Math]::Max($MaxEnergized,($energized.Values | Select-Object -Unique).Count) 
}
$Result = $MaxEnergized

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 8148 (51 for testdata)