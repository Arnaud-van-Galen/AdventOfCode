Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int] $VisibleTreeCount = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$RowCount = $Data.Count
$ColumnCount = $Data[0].Length

for ($x = 0; $x -lt $ColumnCount; $x++) {
    for ($y = 0; $y -lt $RowCount; $y++) {
        if ($x -eq 0 -or $x -eq $ColumnCount - 1 -or $y -eq 0 -or $y -eq $RowCount - 1) { # EdgeDetection
            $VisibleTreeCount++
        } else {
            $ContinueScan = $true

            for ($i = $x - 1; $i -ge 0 -and $ContinueScan; $i--) { # ScanLeft
                if ($Data[$y][$x] -le $Data[$y][$i]) { $ContinueScan = $false }
            }
            if ($ContinueScan) { $VisibleTreeCount++ ; continue } else { $ContinueScan = $true }

            for ($i = $x + 1; $i -le $ColumnCount - 1 -and $ContinueScan; $i++) { # ScanRight
                if ($Data[$y][$x] -le $Data[$y][$i]) { $ContinueScan = $false }
            }
            if ($ContinueScan) { $VisibleTreeCount++ ; continue } else { $ContinueScan = $true }

            for ($i = $y - 1; $i -ge 0 -and $ContinueScan; $i--) { # ScanUp
                if ($Data[$y][$x] -le $Data[$i][$x]) { $ContinueScan = $false }
            }
            if ($ContinueScan) { $VisibleTreeCount++ ; continue } else { $ContinueScan = $true }

            for ($i = $y + 1; $i -le $RowCount - 1 -and $ContinueScan; $i++) { # ScanDown
                if ($Data[$y][$x] -le $Data[$i][$x]) { $ContinueScan = $false }
            }
            if ($ContinueScan) { $VisibleTreeCount++ ; continue } else { $ContinueScan = $true }
        }
    }
}

Write-Host "$VisibleTreeCount trees are visible from the outside of the grid"
# Correct answer = 1684 (21 for testdata)