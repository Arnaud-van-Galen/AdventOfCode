Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

# $TargetArea = @(20, 30, -5, -10)
$TargetArea = @(185, 221, -122, -74)

$TargetXMin = $TargetArea[0..1] | Measure-Object -Minimum | Select-Object -ExpandProperty Minimum
$TargetXMax = $TargetArea[0..1] | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
$TargetYMin = $TargetArea[2..3] | Measure-Object -Minimum | Select-Object -ExpandProperty Minimum
$TargetYMax = $TargetArea[2..3] | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum

$InTargetArea = @()
for ($y = -500; $y -le 500; $y++) {
    for ($x = 0; $x -le $TargetXMax; $x++) {
        $GotInTargetArea = $false
        $ProbeX = 0
        $ProbeY = 0
        $ProbeXVelocity = $x
        $ProbeYVelocity = $y        
        while ($ProbeX -le $TargetXMax -and $ProbeY -ge $TargetYMin) {
            $ProbeX += $ProbeXVelocity
            $ProbeY += $ProbeYVelocity
        
            if ($ProbeXVelocity -gt 0) { $ProbeXVelocity--} 
            elseif ($ProbeXVelocity -lt 0) { $ProbeXVelocity++} 
            $ProbeYVelocity--
        
            if ($ProbeX -in $TargetXMin..$TargetXMax -and $ProbeY -in $TargetYMin..$TargetYMax) {
                $GotInTargetArea = $true
            }
        }
        if ($GotInTargetArea) {
           $InTargetArea += (($x, "," ,$y | Join-String))
        }
    }
}
$InTargetArea.Count
# Correct answer = 3019 (112 for testdata)