Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[double] $Result = 0
$Moves = @{
  '3' = @(0,-1)
  '0' = @(1,0)
  '1' = @(0,1)
  '2' = @(-1,0)
}
$PathLength = 0
$CornerCoordinates = @()
$Position = [PSCustomObject]@{X = 0;Y = 0}
# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
for ($i = 0; $i -lt $Data.Count; $i++) {
  $InstructionRaw = $Data[$i].Split('#')[1]
  $MoveAmount = [Convert]::ToInt32($InstructionRaw.Substring(0,5), 16)
  $Move = $InstructionRaw.Substring(5,1)
  $PathLength += $MoveAmount
  $Position.X+=$Moves[$Move][0]*$MoveAmount
  $Position.Y+=$Moves[$Move][1]*$MoveAmount
  $CornerCoordinates += ,@($Position.X,$Position.Y)
}
$CornerCoordinates += ,@($CornerCoordinates[0])
$ShoelaceArea = 0
for ($i = 0; $i -lt $CornerCoordinates.Count-1; $i++) {
  $x1 = $CornerCoordinates[$i][0]
  $y1 = $CornerCoordinates[$i][1]
  $x2 = $CornerCoordinates[$i + 1][0]
  $y2 = $CornerCoordinates[$i + 1][1]
  $ShoelaceArea+=($x1*$y2)-($y1*$x2)
}
$ShoelaceArea = [System.Math]::Abs($ShoelaceArea/2)
$Result = $ShoelaceArea + $PathLength / 2 + 1

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 45159 (62 for testdata)