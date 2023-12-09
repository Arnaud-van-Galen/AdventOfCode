Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[Int64] $Result = 0
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

$ZMatchings = @()
$Positions = $Mappings.Keys.Where{$_.endswith('A')}
for ($i = 0; $i -lt $Positions.Count; $i++) {
  $Step = 0
  $Repeating = $false
  while (!$Repeating) {
    $Instruction = $Instructions[$Step % $Instructions.Length]
    if ($Instruction -eq 'L') {
      $Positions[$i] = $Mappings[$Positions[$i]][0]
    } else {
      $Positions[$i] = $Mappings[$Positions[$i]][1]
    }
    if ($Positions[$i].EndsWith('Z')) {
      $ZMatchings += $Step+1
      $Repeating = $true
    }
    $Step++
  }
}
$Steps = $ZMatchings
[Int64]$KGV = $Steps[0]
for ($i = 1; $i -lt $Steps.Count; $i++) {
  [Int64]$NextStep = $Steps[$i]
  $KGVOrg = $KGV
  $NextStepOrg = $NextStep
  while ($KGV -ne 0) {
    $KGV_ = $KGV
    $KGV = $NextStep % $KGV
    $NextStep = $KGV_
  }
  $KGV = $KGVOrg * $NextStepOrg / $NextStep 
}
$Result = $KGV

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 16563603485021 (6 for testdata)