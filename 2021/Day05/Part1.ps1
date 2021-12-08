Get-Variable | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[System.Collections.ArrayList] $VentPoints = @()

# [string[]] $VentsInput = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $VentsInput = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

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
Write-Host "Time for finding all VentPoints:", $stopwatch.Elapsed.TotalSeconds

$stopwatch.Restart()
($VentPoints | Group-Object | Where-Object { $_.Count -ge 2 }).Count
Write-Host "Time for finding the amount of dangerous VentPoints with Group-Object and Where-Object:", $stopwatch.Elapsed.TotalSeconds
# Correct answer = 8111 (5 for testdata) in 0.23 + 1.25 seconds