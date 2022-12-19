Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

class SensorRange {
    [int] $Min
    [int] $Max
}

# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
# $Boundaries = 20
[string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
$Boundaries = 4000000

for ($y = 0; $y -le $Boundaries; $y++) {
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
            if ($SensorRange.Min -le 0 -and $SensorRange.Max -ge $Boundaries) {continue}
        }
    }
    $SensorRangesToCheck = $SensorRanges.Where{$_.Max -ge 0 -and $_.Min -le $Boundaries} | Sort-Object -Property Max | Sort-Object -Property Min
    if ($SensorRangesToCheck.Count -ge 2) {
        $MaxValue = $SensorRangesToCheck[0].Max
        for ($j = 1; $j -lt $SensorRangesToCheck.Count; $j++) {
            if ($SensorRangesToCheck[$j].Min -le $MaxValue + 1) {
                if ($SensorRangesToCheck[$j].Max -ge $MaxValue) {
                    $MaxValue = $SensorRangesToCheck[$j].Max
                }
            } else {
                Write-Host "On row $y there is a gap at $($MaxValue + 1). Tuning frequency is $(4000000*($MaxValue + 1) + $y)"
                # exit  
            }
        }
    }
    if ($y % 10000 -eq 0) { Write-Host "$y out of $Boundaries. $($stopwatch.Elapsed.TotalSeconds) seconds elapsed, $($stopwatch.Elapsed.TotalSeconds / $y * $Boundaries) expected" }
}

# Correct answer = 13622251246513 (56000011 for testdata)

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds