$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# [string[]] $VentsInput = Get-Content .\05-1-Demo-Input.txt
[string[]] $VentsInput = Get-Content .\05-1-Input.txt

[System.Collections.ArrayList] $VentPoints = @()
foreach ($LineOfVents in $VentsInput) {
    $x1, $y1, $x2, $y2 = [int[]] $LineOfVents.Split(", ->".ToCharArray(), [System.StringSplitOptions]::RemoveEmptyEntries)
    if ($x1 -eq $x2) {
        if ($y1 -gt $y2) { $y1, $y2 = $y2, $y1 }
        for ( $i = $y1 ; $i -le $y2 ; $i++) { $VentPoints.Add("" + $x1 + "-" + $i) | Out-Null }
    } elseif ($y1 -eq $y2) {
        if ($x1 -gt $x2) { $x1, $x2 = $x2, $x1 }
        for ( $i = $x1 ; $i -le $x2 ; $i++) { $VentPoints.Add("" + $i + "-" + $y1) | Out-Null }
    }
}
Write-Host "Time for finding all VentPoints: ", $stopwatch.Elapsed.TotalSeconds

$stopwatch.Restart()
($VentPoints | Group-Object | Where-Object { $_.Count -ge 2 }).Count
Write-Host "Time for finding the amount of dangerous VentPoints with Group-Object and Where-Object: ", $stopwatch.Elapsed.TotalSeconds
# 8111 in 0.23 + 1.25 seconds