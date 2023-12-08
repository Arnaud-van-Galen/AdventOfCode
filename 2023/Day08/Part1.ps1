Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0
$Step = 0
$Mappings = @{}

# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo2.txt -ErrorAction Stop
[string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
$Instructions = $Data[0]
for ($i = 2; $i -lt $Data.Count; $i++) {
  $DataLine = $Data[$i]
  $DataLineClean = $DataLine.Replace('(','').Replace(')','').Replace(' ','')
  $Instruction, $Mapping = $DataLineClean.Split('=')
  $Mappings[$Instruction] = $Mapping.Split(',')
}

$Position = 'AAA'
while ($Position -ne 'ZZZ') {
  $Instruction = $Instructions[$Step % $Instructions.Length]
  if ($Instruction -eq 'L') {
    $Position = $Mappings[$Position][0]
  } else {
    $Position = $Mappings[$Position][1]
  }
  $Step++
}
$Result = $Step

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 16897 (2 and 6 for testdata)