Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0

# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
[Array]::Reverse($Data)
$DataTransposedClockwise = 
  for ($i = 0; $i -lt $Data[0].Length; $i++) {
    -join $Data.ForEach{$_[$i]}
  }
for ($i = 0; $i -lt $DataTransposedClockwise.Count; $i++) {
  $DataLine = $DataTransposedClockwise[$i]
  while ($RockToMove = [regex]::Matches($DataLine, 'O\.+')[-1] ?? $false) {
    $LeftField = $DataLine.Substring(0, $RockToMove.Index)
    $RightField = -join $DataLine[($RockToMove.Index+$RockToMove.Length)..$DataLine.Length]
    $RockTrack = $RockToMove.Value.ToCharArray()
    [Array]::Reverse($RockTrack)
    $Dataline = $LeftField + (-join $RockTrack) + $RightField
  }
  [regex]::Matches($DataLine, 'O').ForEach{$Result+=$_.Index+1}
  $DataTransposedClockwise[$i]=$DataLine
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 110779 (136 for testdata)