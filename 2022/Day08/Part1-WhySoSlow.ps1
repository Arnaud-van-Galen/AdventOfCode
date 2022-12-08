Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int] $VisibleTreeCount = 0

$Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
# $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$RowCount = $Data.Count
$ColumnCount = $Data[0].Length

for ($x = 0; $x -lt $ColumnCount; $x++) {
    for ($y = 0; $y -lt $RowCount; $y++) { # EdgeDetection
        if ($x -eq 0 -or $x -eq $ColumnCount - 1 -or $y -eq 0 -or $y -eq $RowCount - 1) {
            $VisibleTreeCount++
        } else { # ScanLeft, ScanRight, ScanUp, ScanDown
            if ($Data[$y][$x].ToString() -gt ($Data[$y][0..($x-1)] | ForEach-Object {$_.ToString()} | Measure-Object -Maximum).Maximum) { $VisibleTreeCount++; continue }
            if ($Data[$y][$x].ToString() -gt ($Data[$y][($x+1)..($ColumnCount-1)] | ForEach-Object {$_.ToString()} | Measure-Object -Maximum).Maximum) { $VisibleTreeCount++; continue }
            if ($Data[$y][$x].ToString() -gt ($Data[0..($y-1)].foreach{$_[$x]} | ForEach-Object {$_.ToString()} | Measure-Object -Maximum).Maximum) { $VisibleTreeCount++; continue }
            if ($Data[$y][$x].ToString() -gt ($Data[($y+1)..($RowCount-1)].foreach{$_[$x]} | ForEach-Object {$_.ToString()} | Measure-Object -Maximum).Maximum) { $VisibleTreeCount++; continue }
        }
    }
}

Write-Host "$VisibleTreeCount trees are visible from the outside of the grid"
# Correct answer = 1684 (21 for testdata)