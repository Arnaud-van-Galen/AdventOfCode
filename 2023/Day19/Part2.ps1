Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[Int64] $Result = 0
$Workflows = @{}
$Tests = @{}
"XMAS".ToCharArray().ForEach{$Tests[[string]$_] = [PSCustomObject]@{Min = 1; Max = 4000}}
$Accepted = @()

# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
$DataMode = 'Workflows'
for ($i = 0; $i -lt $Data.Count; $i++) {
  if ($Data[$i] -eq '') {$DataMode = 'PartRatings'} else {
    if ($DataMode -eq 'Workflows') {
      $WorkflowName, $Instructions = $Data[$i].Split('{').TrimEnd('}')
      $Workflows[$WorkflowName] = $Instructions.Split(',')
    }
  }
}

$NewTests = @{}; $Tests.Keys.ForEach{$NewTests[$_] = $Tests[$_] | ConvertTo-Json | ConvertFrom-Json} # DeepCopy
$Stack = [System.Collections.Stack]::new()
$Stack.Push(@($Workflows["in"], 0, $NewTests))
while ($Stack.Count -gt 0) {
  $ActiveWorkFlow, $ActiveWorkFlowStep, $Tests = $Stack.Pop()
  $Step = $ActiveWorkFlow[$ActiveWorkFlowStep]
  if ($Step -match '<') {
    $Part, [int]$Limit, $StepResult = ($Step -replace '<', ':').Split(':')
    $LowerTests = @{}; $Tests.Keys.ForEach{$LowerTests[$_] = $Tests[$_] | ConvertTo-Json | ConvertFrom-Json} # DeepCopy
    $LowerTests[$Part].Max = $Limit-1
    $HigherTests = @{}; $Tests.Keys.ForEach{$HigherTests[$_] = $Tests[$_] | ConvertTo-Json | ConvertFrom-Json} # DeepCopy
    $HigherTests[$Part].Min = $Limit
    if ($StepResult -eq 'A') {$Accepted += $LowerTests}
    elseif ($StepResult -ne 'R') {$Stack.Push(@($Workflows[$StepResult], 0, $LowerTests))}
    $Stack.Push(@($ActiveWorkFlow, ($ActiveWorkFlowStep+1), $HigherTests))
  } elseif ($Step -match '>') {
    $Part, [int]$Limit, $StepResult = ($Step -replace '>', ':').Split(':')
    $LowerTests = @{}; $Tests.Keys.ForEach{$LowerTests[$_] = $Tests[$_] | ConvertTo-Json | ConvertFrom-Json} # DeepCopy
    $LowerTests[$Part].Max = $Limit
    $HigherTests = @{}; $Tests.Keys.ForEach{$HigherTests[$_] = $Tests[$_] | ConvertTo-Json | ConvertFrom-Json} # DeepCopy
    $HigherTests[$Part].Min = $Limit+1
    if ($StepResult -eq 'A') {$Accepted += $HigherTests}
    elseif ($StepResult -ne 'R') {$Stack.Push(@($Workflows[$StepResult], 0, $HigherTests))}
    $Stack.Push(@($ActiveWorkFlow, ($ActiveWorkFlowStep+1), $LowerTests))
  } elseif ($Step -eq 'A') {
    $NewTests = @{}; $Tests.Keys.ForEach{$NewTests[$_] = $Tests[$_] | ConvertTo-Json | ConvertFrom-Json} # DeepCopy
    $Accepted += $NewTests
  } elseif ($Step -ne 'R') {
    $NewTests = @{}; $Tests.Keys.ForEach{$NewTests[$_] = $Tests[$_] | ConvertTo-Json | ConvertFrom-Json} # DeepCopy
    $Stack.Push(@($Workflows[$Step], 0, $NewTests))
  }
}

for ($i = 0; $i -lt $Accepted.Count; $i++) {
  $tempresult = 1
  ($Accepted[$i].Keys.Foreach{$Accepted[$i][$_].Max - $Accepted[$i][$_].Min + 1}).Foreach{$tempresult=($_*$tempresult)}
  $Result += $tempresult 
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 131192538505367 (167409079868000 for testdata)