Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0
$Step = 0
$Mappings = @{}

# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo3.txt -ErrorAction Stop
[string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
$Instructions = $Data[0]
for ($i = 2; $i -lt $Data.Count; $i++) {
  $DataLine = $Data[$i]
  $DataLineClean = $DataLine.Replace('(','').Replace(')','').Replace(' ','')
  $Instruction, $Mapping = $DataLineClean.Split('=')
  $Mappings[$Instruction] = $Mapping.Split(',')
}

$MaxZCount=0
$Positions = $Mappings.Keys.Where{$_.endswith('A')}
while ($Positions.Where{$_.endswith('Z')}.Count -ne $Positions.Count) {
  $Instruction = $Instructions[$Step % $Instructions.Length]
  for ($i = 0; $i -lt $Positions.Count; $i++) {
    if ($Instruction -eq 'L') {
      $Positions[$i] = $Mappings[$Positions[$i]][0]
    } else {
      $Positions[$i] = $Mappings[$Positions[$i]][1]
    }
  }
  $ZCount = $Positions.Where{$_.endswith('Z')}.Count
  if ($MaxZCount -lt $ZCount) {
    $MaxZCount = $ZCount
    Write-Host $Step, $MaxZCount, $Positions
  }
  $Step++
}
$Result = $Step

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 16897 (6 for testdata)