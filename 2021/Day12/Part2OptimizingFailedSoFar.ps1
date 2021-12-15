# ToDo: Try to only calculate the $HasDoubleVisited once during if ($PossibleNextPath -cin $SmallCavesVisited) by passing it as an argument
Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

$StartCave = "start"
$EndCave = "end"
$JourneyCount = 0
function GetNextPaths { param ( [string[]] $CurrentJourney, [string[]] $SmallCavesVisited, [bool] $HasDoubleVisited, [string] $DoubleVisitedReason )
    $CurrentCave = $CurrentJourney[-1]
    if ($CurrentCave -ceq $CurrentCave.ToLower()) { $SmallCavesVisited += $CurrentCave }
    Write-Host "CurrentJourney:", $CurrentJourney, "SmallCavesVisited:", $SmallCavesVisited, "HasDoubleVisited:", $HasDoubleVisited
    # Twice as slow: if ($SmallCavesVisited | Group-Object -NoElement | Where-Object -Property Count -ne 1) {
    if ($CurrentCave -ceq $CurrentCave.ToLower()) { $SmallCavesVisited += $CurrentCave }
        $PossibleNextPaths = $Caves[$CurrentCave].Where{$_ -cnotin $SmallCavesVisited}
    } else {
        $PossibleNextPaths = $Caves[$CurrentCave]
    }
    # Write-Host "PossibleNextPaths:", $PossibleNextPaths
    foreach ($PossibleNextPath in $PossibleNextPaths) {
        if ($PossibleNextPath -cin $SmallCavesVisited) { 
            $HasDoubleVisited = $true
            $DoubleVisitedReason = "During journey '$($CurrentJourney)' the nextPath would be '$($PossibleNextPath)' which was already in '$($SmallCavesVisited)'"
        }
        # $HasDoubleVisited = ($HasDoubleVisited -or $PossibleNextPath -cin $SmallCavesVisited)
        [bool] $DetectSmallCavesVisitedTwice = if ($SmallCavesVisited | Group-Object -NoElement | Where-Object -Property Count -ne 1) {$true} else {$false}
        [bool] $DetectSmallCavesToBeVisitedTwice = if (($SmallCavesVisited + $PossibleNextPath) | Group-Object -NoElement | Where-Object -Property Count -ne 1) {$true} else {$false}
        if ($DetectSmallCavesToBeVisitedTwice -ne $HasDoubleVisited) {
            Write-Host "About to call the next iteration with:"
            Write-Host ($CurrentJourney + $PossibleNextPath)
            Write-Host $SmallCavesVisited
            Write-Host "expected:", $DetectSmallCavesToBeVisitedTwice, "gotten:", $HasDoubleVisited
            Write-Host $DoubleVisitedReason
            Write-Host "--------------------------------------------------------------"
        }
        GetNextPaths -CurrentJourney ($CurrentJourney + $PossibleNextPath) -SmallCavesVisited $SmallCavesVisited -HasDoubleVisited $HasDoubleVisited -DoubleVisitedReason $DoubleVisitedReason
    }
    if ($CurrentCave -ceq $EndCave) {
        # Write-Host "This Journey has ended:", ($CurrentJourney -join "-")
        $Script:JourneyCount++
    }
}

[string[]] $Paths = Get-Content -Path $PSScriptRoot\DataDemo1.txt -ErrorAction Stop
# [string[]] $Paths = Get-Content -Path $PSScriptRoot\DataDemo2.txt -ErrorAction Stop
# [string[]] $Paths = Get-Content -Path $PSScriptRoot\DataDemo3.txt -ErrorAction Stop
# [string[]] $Paths = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

# Build up a Caves object and fill it up with the basic properties and the adjacents
$Caves = [hashtable]::new() # Case sensitive creator, while @{} is case insensitive
$FoundCaves = $Paths.Split("-") | Sort-Object -Unique -CaseSensitive
$FoundCaves.ForEach{ $Caves.Add($_, [string[]] @() ) }
foreach ($Path in $Paths) {
    $Cave1, $Cave2 = $Path.Split("-")
    if ($Cave2 -ceq $StartCave -or $Cave1 -ceq $EndCave) { $Cave1, $Cave2 = $Cave2, $Cave1 } # Order paths with StartCaves and EndCaves for easier handling
    if ($Cave1 -cne $StartCave -and $Cave2 -cne $EndCave) { $Caves[$Cave2] += $Cave1 } # Don't go back to StartCave or after EndCave
    $Caves[$Cave1] += $Cave2
}

GetNextPaths -CurrentJourney $StartCave

$JourneyCount
# Correct answer = 108035 in 73,36 (36 for testdata1 in 0,04 sec, 103 for testdata2 in 0,08 sec, 3509 for testdata3 in 3.48 sec)
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds