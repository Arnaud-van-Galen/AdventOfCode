Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0
$Workflows = @{}

# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
$DataMode = 'Workflows'
for ($i = 0; $i -lt $Data.Count; $i++) {
  if ($Data[$i] -eq '') {$DataMode = 'PartRatings'} else {
    if ($DataMode -eq 'Workflows') {
      $WorkflowName, $Instructions = $Data[$i].Split('{').TrimEnd('}')
      $Workflows[$WorkflowName] = $Instructions.Split(',')
    } else {
      [int[]]$Ratings = [regex]::Matches($Data[$i],'\d+').Value
      $PartRatings=[ordered]@{}
      $PartRatings['X']=$Ratings[0]
      $PartRatings['M']=$Ratings[1]
      $PartRatings['A']=$Ratings[2]
      $PartRatings['S']=$Ratings[3]
      $ActiveWorkFlow = $Workflows['in']
      $ActiveWorkFlowStep = 0
      $WorkflowResult = $null
      while (!$WorkflowResult) {
        do {
          $Step = $ActiveWorkFlow[$ActiveWorkFlowStep]
          if ($Step -match '>') {
            $Part, [int]$Limit, $StepResult = ($Step -replace '>', ':').Split(':')
            if (!($PartRatings[$Part] -gt $Limit)) { $StepResult = 'Next' }
          } elseif ($Step -match '<') {
            $Part, $Limit, $StepResult = ($Step -replace '<', ':').Split(':')
            if (!($PartRatings[$Part] -lt $Limit)) { $StepResult = 'Next' }
          } else {
            $StepResult = $Step
          }
          if ($StepResult -eq 'A' -or $StepResult -eq 'R') {
            $ActiveWorkFlowStep = $ActiveWorkFlow.Count
            $WorkflowResult = $StepResult
          } elseif ($StepResult -eq 'Next') {
            $ActiveWorkFlowStep++
          } else {
            $ActiveWorkFlow = $Workflows[$StepResult]
            $ActiveWorkFlowStep = 0
          }
        } while ($ActiveWorkFlowStep -lt $ActiveWorkFlow.Count)
      }
      if ($WorkflowResult -eq 'A') {$PartRatings.Values.ForEach{$Result += $_}}
    }
  }
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 406934 (19114 for testdata)