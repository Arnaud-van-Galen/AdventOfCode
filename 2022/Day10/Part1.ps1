Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

$X = 1
$Cycle = 0
$CycleValues = @{ $Cycle = $X }
$SignalStrengthSum = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
# $Data = Get-Content -Path $PSScriptRoot\DataDemo2.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

foreach ($Instruction in $Data) {
    if ($Instruction -eq "noop") {
        $Cycle++
        $CycleValues[$Cycle] += $X
    } else {
        $Cycle++
        $CycleValues[$Cycle] += $X
        $Cycle++
        $X += $Instruction.Split()[1]
        $CycleValues[$Cycle] += $X
    }
}

for ($InterestingSignalStrengths = 20; $InterestingSignalStrengths -lt $CycleValues.Count; $InterestingSignalStrengths += 40) {
    $SignalStrengthSum += $InterestingSignalStrengths * $CycleValues[$InterestingSignalStrengths - 1] 
}

$SignalStrengthSum
# Correct answer = 14240 (13140 for 2nd testdata. 1st testdata should be visually compared to $cycleValues | ft | clip)