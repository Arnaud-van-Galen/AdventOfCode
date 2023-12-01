Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

<# Shapes
####            ..####.

.#.             ...#...
###             ..###..
.#.             ...#...

..#             ....#..
..#             ....#..
###             ..###..

#               ..#....
#               ..#....
#               ..#....
#               ..#....

##              ..##...
##              ..##...
#>

$ChamberWidth = 7
$RockCount = 2022
$StartFromLeft = 2
$StartFromResting = 3
$Shape1 = [array]::new(4)
$Shape1[0] = ($true,$true,$true,$true,$false,$false,$false)
$Shape1[1] = ($false,$true,$true,$true,$true,$false,$false)
$Shape1[2] = ($false,$false,$true,$true,$true,$true,$false)
$Shape1[3] = ($false,$false,$false,$true,$true,$true,$true)
$Shape2 = [array]::new(5)
$Shape1[0] = ($false,$true,$true,$true,$false,$false,$false),($true,$true,$true,$true,$false,$false,$false),($true,$true,$true,$true,$false,$false,$false)





[string] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -Raw -ErrorAction Stop
# [string] $Data = Get-Content -Path $PSScriptRoot\Data.txt -Raw -ErrorAction Stop




# Correct answer = ? (3068 for testdata)

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds