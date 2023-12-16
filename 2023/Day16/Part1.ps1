Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

$sha256 = [System.Security.Cryptography.SHA256]::Create()

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
$Energized = @{}

# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
$GridWidth = $Data[0].Length
$GridHeight = $Data.Length

$stack = [System.Collections.Stack]::new()
$stack.Push(@(0,0,'R'))

while ($stack.Count -gt 0) {
  $X, $Y, $Move = $stack.Pop()
  $Energized[-join $sha256.ComputeHash((''+$X+','+$Y+','+$Move).ToCharArray())] = ''+$X+','+$Y
  $TileMoves = $Tiles[$Data[$Y][$X].ToString()][$Move]
  $TileMoves.ForEach{
    $NewX = $X + $Moves[$_][0]
    $NewY = $Y + $Moves[$_][1]
    if ($NewX -ge 0 -and $NewX -lt $GridWidth -and $NewY -ge 0 -and $NewY -lt $GridHeight) {
      if (!$Energized[-join $sha256.ComputeHash((''+$NewX+','+$NewY+','+$_).ToCharArray())]) {
        $stack.Push(@($NewX,$NewY,$_))
      }
    }
  }
}
$Result = ($energized.Values | Select-Object -Unique).Count

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 7951 (46 for testdata)