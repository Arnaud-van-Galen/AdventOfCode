Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

function GrootsteGemeneDeler {param($a, $b)
  while ($a -ne 0) {
    $a_ = $a
    $a = $b % $a
    $b = $a_
  }
  return $b
}

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

$ZMatchings = @{}
$ZMatchingsObject = @()
$Positions = $Mappings.Keys.Where{$_.endswith('A')}
# 0=20221 at 276 (277*73)
# 1=11911 at 276 (277*43)
# 2=21883 at 276 (277*79)
# 3=16343 at 276 (277*59)
# 4=18559 at 276 (277*67)
# 5=16897 at 276 (277*61)
# all those numbers are prime, so 73*43*79*59*67*61 = 59796402473
# 277 is also prime, so 59796402473 * 277 = 16563603485021
# Het is wel HEEL toevallig dat elke ..A-input precies na X loops van de instructions op precies 1 uniek ..Z terechtkomt
# Het is ook HEEL toevallig dat dat aantal X loops en het aantal instruction-characters ook priemgetallen zijn 
for ($i = 0; $i -lt $Positions.Count; $i++) {
  $PositionBegin = $Positions[$i]
  $Step = 0
  $ZMatch = 0
  $Repeating = $false
  while (!$Repeating -and $Step -le 2*$Instructions.Length*$Mappings.Count) {
    $Instruction = $Instructions[$Step % $Instructions.Length]
    if ($Instruction -eq 'L') {
      $Positions[$i] = $Mappings[$Positions[$i]][0]
    } else {
      $Positions[$i] = $Mappings[$Positions[$i]][1]
    }
    if ($Positions[$i].EndsWith('Z')) {
      $PossibleNewZMatch = @(($Step % $Instructions.Length), $Positions[$i], ($Mappings[$Positions[$i]] -join '-')) -join '-'
      if (!$ZMatchings.ContainsValue($PossibleNewZMatch)) {
        $ZMatchings[$i,$ZMatch,$Step -join '-'] = $PossibleNewZMatch
        $ZMatchingsObject += [PSCustomObject]@{
          Index = $i
          Name = $PositionBegin
          Match = $ZMatch +1
          Step = $Step + 1
          Instruction = $Step % $Instructions.Length
          End = $Positions[$i]
          FromMapping = $Mappings[$Positions[$i]]
        }
        Write-Host $i, ("{0:N0}" -f $Step), ($Step % $Instructions.Length), $Positions[$i], $Mappings[$Positions[$i]]
        $ZMatch++
      } else {
        $Repeating = $true
      }
    }
    $Step++
  }
}

$GroupsToAnalyze = $zMatchingsObject | Group-Object Instruction | Where-Object {$_.Count -eq $Positions.Count} | Select-Object Group
$Steps = $GroupsToAnalyze.Group.Step
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