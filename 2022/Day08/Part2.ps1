Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int] $ScenicScoreMax = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$RowCount = $Data.Count
$ColumnCount = $Data[0].Length

for ($x = 0; $x -lt $ColumnCount; $x++) {
    for ($y = 0; $y -lt $RowCount; $y++) { # EdgeDetection
        if ($x -ne 0 -and $x -ne $ColumnCount - 1 -and $y -ne 0 -and $y -ne $RowCount - 1) {
            $ScanLeft, $ScanRight, $ScanUp, $ScanDown, $ScenicScore = 0
            $ContinueScan=$true
            for ($i = $x - 1; $i -ge 0 -and $ContinueScan; $i--) {
                $ScanLeft++
                if ($Data[$y][$x] -le $Data[$y][$i]) { $ContinueScan = $false}
            }
            $ContinueScan=$true
            for ($i = $x + 1; $i -le $ColumnCount - 1 -and $ContinueScan; $i++) {
                $ScanRight++
                if ($Data[$y][$x] -le $Data[$y][$i]) { $ContinueScan = $false}
            }
            $ContinueScan=$true
            for ($i = $y - 1; $i -ge 0 -and $ContinueScan; $i--) {
                $ScanUp++
                if ($Data[$y][$x] -le $Data[$i][$x]) { $ContinueScan = $false}
            }
            $ContinueScan=$true
            for ($i = $y + 1; $i -le $RowCount - 1 -and $ContinueScan; $i++) {
                $ScanDown++
                if ($Data[$y][$x] -le $Data[$i][$x]) { $ContinueScan = $false}
            }
            $ScenicScore = $ScanLeft * $ScanRight * $ScanUp * $ScanDown
            if ($ScenicScore -gt $ScenicScoreMax) {
                $ScenicScoreMax = $ScenicScore
            }
        }
    }
}

Write-Host "$ScenicScoreMax"
# Correct answer = 486540 (8 for testdata)