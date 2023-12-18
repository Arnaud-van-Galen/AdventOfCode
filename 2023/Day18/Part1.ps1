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
$Path = [ordered]@{}
$Position = [PSCustomObject]@{X = 0;Y = 0}
$MinX = $MaxX = $MinY = $MaxY = 0

[string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
# [string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
for ($i = 0; $i -lt $Data.Count; $i++) {
  [string]$Move, [int]$MoveAmount, $Color = $Data[$i].Split(' ')
  while ($MoveAmount -gt 0) {
    $Position.X+=$Moves[$Move][0]
    $Position.Y+=$Moves[$Move][1]
    $Path["$($Position.X),$($Position.Y)"] += 1
    if ($Position.X -gt $MaxX) {$MaxX = $Position.X}
    if ($Position.X -lt $MinX) {$MinX = $Position.X}
    if ($Position.Y -gt $MaxY) {$MaxY = $Position.Y}
    if ($Position.Y -lt $MinY) {$MinY = $Position.Y}
    $MoveAmount--
  }
}
$GridWidth = $MaxX-$MinX+1
$GridHeight = $MaxY-$MinY+1

$PathArray = (' '*$GridHeight*$GridWidth).ToCharArray()
$Path.Keys.ForEach{
  [int]$X, [int]$Y = $_.split(',')
  $X = $X - $MinX
  $Y = $Y - $MinY
  $PathArray[$Y*$GridWidth+$X]='#'
}

$ChangesMade = $true
while ($ChangesMade) {
  $ChangesMade = $false
  for ($i = 0; $i -lt $PathArray.Count; $i++) {
    if ($PathArray[$i] -eq ' ') {
      if ($i -in @(0..($GridWidth-1)) -or $i % $GridWidth -eq 0 -or $i % $GridWidth -eq $GridWidth-1 -or $i -in @((($GridHeight-1)*$GridWidth)..($PathArray.count))) {
        $PathArray[$i] = '.'
        $ChangesMade = $true
      } elseif ($PathArray[$i-$GridWidth] -eq '.' -or $PathArray[$i-1] -eq '.' -or $PathArray[$i+1] -eq '.' -or $PathArray[$i+$GridWidth] -eq '.') {
        $PathArray[$i] = '.'
        $ChangesMade = $true
      }
    }
  }
}

$Result = ($PathArray | select-String '#| ' -AllMatches).Matches.count

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 45159 (62 for testdata)