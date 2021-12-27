Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

$FileData = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
# $FileData = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$Algorithm = $FileData[0]
$InputImage = $FileData[2..$FileData.Count]

$TotalEnhanceCount = 2
$CurrentEnhanceCount = 0

function GrowInputImage {
    [System.Collections.BitArray]::new($BiggerGridWidth * $BiggerGridheight)
    $InputImage.Add("." * $InputImage[0].Length)
}
$InputImage
exit
for ($Enhance = 1; $Enhance -le $EnhanceCount; $Enhance++) {
    for ($y = $EnhanceCount - $Enhance; $y -lt $Enhance + $SmallGridHeight + $Enhance; $y++) {
        for ($x = $EnhanceCount - $Enhance; $x -lt $Enhance + $SmallGridWidth + $Enhance; $x++) {
            #Get-MyVariables
        }
    }
}



$SmallGridWidth = $InputImage[0].Length
$SmallGridHeight = $InputImage.Count
$BiggerGridWidth = $EnhanceCount + $SmallGridWidth + $EnhanceCount
$BiggerGridheight = $EnhanceCount + $SmallGridHeight + $EnhanceCount

$BigGrid = [System.Collections.BitArray]::new($BiggerGridWidth * $BiggerGridheight)
for ($y = 0; $y -lt $InputImage.Count; $y++) {
    for ($x = 0; $x -lt $InputImage[0].Length; $x++) {
        if ($InputImage[$y][$x] -eq "#") { 
            $BigGrid[($EnhanceCount + $y) * $BiggerGridWidth + $EnhanceCount + $x] = $true}
    }
}
for ($Enhance = 1; $Enhance -le $EnhanceCount; $Enhance++) {
    for ($y = $EnhanceCount - $Enhance; $y -lt $Enhance + $SmallGridHeight + $Enhance; $y++) {
        for ($x = $EnhanceCount - $Enhance; $x -lt $Enhance + $SmallGridWidth + $Enhance; $x++) {
            #Get-MyVariables
        }
    }
}
Write-Host "Het resultaat was:", $WholePairSet
# Correct answer = 3793 (35 voor testdata)