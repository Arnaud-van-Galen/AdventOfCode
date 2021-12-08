Get-Variable | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

$VentPoints = [Object[]]::new(1000000)

# [string[]] $VentsInput = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $VentsInput = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

foreach ($LineOfVents in $VentsInput) {
    $x1, $y1, $x2, $y2 = [int[]] $LineOfVents.Split(", ->".ToCharArray(), [System.StringSplitOptions]::RemoveEmptyEntries)
    if ($x1 -eq $x2) {
        if ($y1 -gt $y2) { $y1, $y2 = $y2, $y1 }
        for ( $i = $y1 ; $i -le $y2 ; $i++) { $VentPoints[$x1 * 1000 + $i]++ }
    } elseif ($y1 -eq $y2) {
        if ($x1 -gt $x2) { $x1, $x2 = $x2, $x1 }
        for ( $i = $x1 ; $i -le $x2 ; $i++) { $VentPoints[$i * 1000 + $y1]++ }
    } else {
        [bool] $DiagonalUp = $y1 -gt $y2
        if ($x1 -gt $x2) { $x1, $x2, $y1, $y2, $DiagonalUp = $x2, $x1, $y2, $y1, !$DiagonalUp }
        for ( $i = $x1 ; $i -le $x2 ; $i++) { 
            if ($DiagonalUp) { 
                $VentPoints[$i * 1000 + $x1 - $i + $y1]++
            } else {
                $VentPoints[$i * 1000 + $i - $x1 + $y1]++
            }
        }
    }
}
Write-Host "Time for finding all VentPoints:", $stopwatch.Elapsed.TotalSeconds

$stopwatch.Restart()
($VentPoints.Where( {$_ -ge 2} )).Count
Write-Host "Time for finding the amount of dangerous VentPoints with .Where:", $stopwatch.Elapsed.TotalSeconds
# This should have been exactly as fast as the foreach, but it is somehow extremely slow

$stopwatch.Restart()
[int] $dangerous = 0
foreach ($VentPoint in $VentPoints) { if ($VentPoint -ge 2) { $dangerous++ } }
$dangerous
Write-Host "Time for finding the amount of dangerous VentPoints with foreach:", $stopwatch.Elapsed.TotalSeconds
# This is very fast

$stopwatch.Restart()
[int] $dangerous = 0
for ($i = 0 ; $i -lt $VentPoints.Count ; $i++) { if ($VentPoints[$i] -ge 2) { $dangerous++ } }
$dangerous
Write-Host "Time for finding the amount of dangerous VentPoints with for:", $stopwatch.Elapsed.TotalSeconds
# This is almost as fast as the foreach, but even if you hardcode the $VentPoints.Count to 1000000 it is still slower

# Correct answer = 22088 (12 for testdata) in 0.09 + 0.05 seconds (foreach) or 0.07 seconds (for) or 1.16 seconds (.Where)