Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

$sha256 = [System.Security.Cryptography.SHA256]::Create()

[int] $Result = 0
$cycles = 1000000000
$CachedResults = @{}
$RepeatingCount = 0

# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

for ($tilt = 0; $tilt -lt 4*$cycles; $tilt++) {
  [Array]::Reverse($Data)
  $Data = 
    for ($i = 0; $i -lt $Data[0].Length; $i++) {
      -join $Data.ForEach{$_[$i]}
    }

  if ($tilt % 4 -eq 0) {
    $Result = 0
    for ($f = 0; $f -lt $Data.Count; $f++) {
      [regex]::Matches($Data[$f], 'O').ForEach{$Result+=$_.Index+1}
    }
  }

  for ($i = 0; $i -lt $Data.Count; $i++) {
    $DataLine = $Data[$i]
    while ($RockToMove = [regex]::Matches($DataLine, 'O\.+')[-1] ?? $false) {
      $LeftField = $DataLine.Substring(0, $RockToMove.Index)
      $RightField = -join $DataLine[($RockToMove.Index+$RockToMove.Length)..$DataLine.Length]
      $RockTrack = $RockToMove.Value.ToCharArray()
      [Array]::Reverse($RockTrack)
      $Dataline = $LeftField + (-join $RockTrack) + $RightField
    }
    $Data[$i]=$DataLine
  }
  
  if ($tilt % 4 -eq 0) {
    $DataToStore = -join $sha256.ComputeHash($data.ToCharArray())
    if ($CachedResults[$DataToStore]) {
      $RepeatingCount = $tilt-$CachedResults[$DataToStore][0]
      break
    }
    $CachedResults[$DataToStore] = @($tilt, $Result)
  }
}
$Result = $CachedResults[$CachedResults.Keys.Where{($CachedResults[$_][0]%$RepeatingCount) -eq (4*$cycles)%$RepeatingCount}][-1][1]

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 86069 (64 for testdata)