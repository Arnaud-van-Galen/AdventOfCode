Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

class SensorRange {
    [int] $Min
    [int] $Max
}
$BeaconPositionsInRowY = @{}

# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
# $y = 10
[string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
$y = 2000000

$SensorRanges = [SensorRange[]]::New($Data.Count)
for ($i = 0; $i -lt $Data.Count; $i++) {
    $Scan = $Data[$i]
    $SensorRange = [SensorRange]::New()
    [int] $SensorX, [int] $SensorY, [int] $BeaconX, [int] $BeaconY = $Scan.Split("=,:".ToCharArray())[1,3,5,7]
    $ManhattanDistance = [System.Math]::abs($SensorX - $BeaconX) + [System.Math]::abs($SensorY - $BeaconY)
    $VerticalDistance = [System.Math]::abs($SensorY - $y)
    if ($VerticalDistance -le $ManhattanDistance) {
        $SensorRange.Min = $SensorX - ($ManhattanDistance - $VerticalDistance)
        $SensorRange.Max = $SensorX + ($ManhattanDistance - $VerticalDistance)
        $SensorRanges[$i] = $SensorRange
        if ($BeaconY -eq $y) { $BeaconPositionsInRowY[$BeaconX] += 1 }
    }
}

function MergeSensorRanges { param ([SensorRange[]] $SensorRangesUnMerged)
    $SensorRangesUnMerged = $SensorRangesUnMerged | Sort-Object -Property Min
    for ($i = 1; $i -lt $SensorRangesUnMerged.Count; $i++) {
        if ($SensorRangesUnMerged[$i].Min -le $SensorRangesUnMerged[$i - 1].Max + 1) {
            if ($SensorRangesUnMerged[$i].Max -ge $SensorRangesUnMerged[$i - 1].Max) {
                $SensorRangesUnMerged[$i - 1].Max = $SensorRangesUnMerged[$i].Max
            }
            $SensorRangesUnMerged[$i] = $null
            return $SensorRangesUnMerged.Where{ $null -ne $_}
        }
    }
    return $SensorRangesUnMerged
}

do { $SensorRangesMerged = MergeSensorRanges -SensorRangesUnMerged $SensorRanges
    $HasChanged = $false
    if ($SensorRangesMerged.Count -ne $SensorRanges.Count) {
        $SensorRanges = [SensorRange[]] $SensorRangesMerged
        $HasChanged = $true
    }
} while ($HasChanged -eq $true)

$BeaconInSensorRangeCount = ($SensorRanges.ForEach{ $_.Max - $_.Min + 1 } | Measure-Object -Sum).sum
for ($i = 0; $i -lt $SensorRanges.Count; $i++) {
    foreach ($BeaconPositionInRowY in $BeaconPositionsInRowY.Keys) {
        if ($BeaconPositionsInRowY[$BeaconPositionInRowY] -ge $SensorRanges[$i].Min -and $BeaconPositionsInRowY[$BeaconPositionInRowY] -le $SensorRanges[$i].Max ) {
            $BeaconInSensorRangeCount--
        }
    }
}
$BeaconInSensorRangeCount
# Correct answer = 4724228 (26 for testdata)

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds