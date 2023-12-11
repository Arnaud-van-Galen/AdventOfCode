Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[Int64] $Result = 0
$expansionValue = 1000000-1 # 2, 10, 100, 1000000
$Galaxies = [System.Collections.ArrayList]::new()

# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
$GridWidth = $Data[0].Length
$GridHeight = $Data.Length
$AllData = $Data -join ''
($AllData | Select-String '#' -AllMatches).Matches.ForEach{
  $Galaxies.Add([int[]]@([System.Math]::Floor(($_.Index / $GridWidth)), ($_.Index % $GridWidth))) | Out-Null
}
$RowsWithGalaxies = $Galaxies.ForEach{$_[0]}
$ColumnsWithGalaxies = $Galaxies.ForEach{$_[1]}
$RowsWithoutGalaxies = (Compare-Object @(0..($GridHeight-1)) $RowsWithGalaxies).Where{$_.SideIndicator -eq '<='}.InputObject
$ColumnsWithoutGalaxies = (Compare-Object @(0..($Gridwidth-1)) $ColumnsWithGalaxies).Where{$_.SideIndicator -eq '<='}.InputObject

[Int64]$Total=0
for ($GalaxyA = 0; $GalaxyA -lt $Galaxies.Count; $GalaxyA++) {
  for ($GalaxyB = $Galaxies.Count-1; $GalaxyB -gt $GalaxyA; $GalaxyB--) {
    $ColumnMax = [System.Math]::Max($Galaxies[$GalaxyA][1],$Galaxies[$GalaxyB][1])
    $ColumnMin = [System.Math]::Min($Galaxies[$GalaxyA][1],$Galaxies[$GalaxyB][1])
    $RowMax = [System.Math]::Max($Galaxies[$GalaxyA][0],$Galaxies[$GalaxyB][0])
    $RowMin = [System.Math]::Min($Galaxies[$GalaxyA][0],$Galaxies[$GalaxyB][0])
    $ExtraColumns = ($ColumnsWithoutGalaxies.Where{$_ -gt $ColumnMin -and $_ -lt $ColumnMax}.Count)*$expansionValue
    $extraRows = ($RowsWithoutGalaxies.Where{$_ -gt $RowMin -and $_ -lt $RowMax}.Count)*$expansionValue
    $Total = $total + ($ColumnMax - $ColumnMin + $ExtraColumns) + ($RowMax - $RowMin + $extraRows)
  }
}
$Result = $Total

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 904633799472 (374, 1030, 8410 for testdata)