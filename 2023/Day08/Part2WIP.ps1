Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0
$Mappings = @{}

# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo3.txt -ErrorAction Stop
[string[]] $Data = Get-Content -Path $PSScriptRoot\DataFokko.txt -ErrorAction Stop
# [string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
$Instructions = $Data[0]
for ($i = 2; $i -lt $Data.Count; $i++) {
  $DataLine = $Data[$i]
  $DataLineClean = $DataLine.Replace('(','').Replace(')','').Replace(' ','')
  $Instruction, $Mapping = $DataLineClean.Split('=')
  $Mappings[$Instruction] = $Mapping.Split(',') #+ @(0,0)
}

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
  $Step = 0
  # while ($Positions.Where{$_.endswith('Z')}.Count -ne $Positions.Count) {
  while ($Step -le 2*$Instructions.Length*$Mappings.Count) {
    $Instruction = $Instructions[$Step % $Instructions.Length]
    if ($Instruction -eq 'L') {
      $Positions[$i] = $Mappings[$Positions[$i]][0]
    } else {
      $Positions[$i] = $Mappings[$Positions[$i]][1]
    }
    if ($Positions[$i].EndsWith('Z')) {
      Write-Host $i, ("{0:N0}" -f $Step), ($Step % $Instructions.Length), $Positions[$i], $Mappings[$Positions[$i]]
    }
    $Step++
  }
}
$Result = $Step

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 16563603485021 (6 for testdata)