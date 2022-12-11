Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

$KnotsCount = 10 # 2 for part1, 10 for part2, but other options are also possible
$AnimationShowResultImmediately = $false # Set to $true to skip the animation and immediately show the final grid.
$AnimationShowTailTrail = $true # set to $false if you don't want to mark positions that were visited by the tail. Beware!: Positions cannot be marked if they are occupied 
$AnimationShowAnalysis = $true # set to $false to hide the information that helps you analyse what is happening
$AnimationMaxFPS = 5 # set to $null to remove all limits. 5 is a nice pace to see the animation. 0.2 is a nice pace to study what is happening. 0 will pause after every move
$AnimationBlankScreen = $true # set to $false if you want to scroll through the output and see some of the previous move(s)
$AnimationFunny = $false # set this to $true, I dare you (gives some artifacts based on your font)

$TailPositions = @{"0, 0" = 1}
$KnotsX = @(0) * $KnotsCount
$KnotsY = @(0) * $KnotsCount
$AnimationKnotPositions = @{ 0 = @($KnotsX.ForEach{ $_ }, $KnotsY.ForEach{ $_ }, "Instruction: ", "Unique TailPositionCount: ") }
$AnimationMinX, $AnimationMaxX, $AnimationMinY, $AnimationMaxY = 0, 0, 0 ,0
$AnimationFramesCount = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
# $Data = Get-Content -Path $PSScriptRoot\DataDemo2.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

foreach ($HeadInstruction in $Data) {
    $HeadDirection, $HeadAmount = $HeadInstruction.Split()
    for ($HeadMove = 0; $HeadMove -lt $HeadAmount; $HeadMove++) {
        for ($CurrentKnot = 0; $CurrentKnot -lt $KnotsCount; $CurrentKnot++) {
            if ($CurrentKnot -eq 0) {
                if ($HeadDirection -eq "U") { $KnotsY[$CurrentKnot]++ }
                elseif ($HeadDirection -eq "D") { $KnotsY[$CurrentKnot]-- }
                elseif ($HeadDirection -eq "L") { $KnotsX[$CurrentKnot]-- }
                elseif ($HeadDirection -eq "R") { $KnotsX[$CurrentKnot]++ }
            } else {
                $HorizontalDistance = $KnotsX[$CurrentKnot - 1] - $KnotsX[$CurrentKnot]
                $VerticalDistance = $KnotsY[$CurrentKnot - 1] - $KnotsY[$CurrentKnot]
                $IsDiagonal = ($KnotsX[$CurrentKnot - 1] -ne $KnotsX[$CurrentKnot] -and $KnotsY[$CurrentKnot - 1] -ne $KnotsY[$CurrentKnot])
                if ($IsDiagonal -and ([System.Math]::Abs($HorizontalDistance) -eq 2 -or [System.Math]::Abs($VerticalDistance) -eq 2)) { # Move diagonally
                    $KnotsX[$CurrentKnot] += $HorizontalDistance / [System.Math]::Abs($HorizontalDistance)
                    $KnotsY[$CurrentKnot] += $VerticalDistance / [System.Math]::Abs($VerticalDistance)
                } elseif ([System.Math]::Abs($HorizontalDistance) -eq 2) {
                    $KnotsX[$CurrentKnot] += $HorizontalDistance / [System.Math]::Abs($HorizontalDistance)
                } elseif ([System.Math]::Abs($VerticalDistance) -eq 2) {
                    $KnotsY[$CurrentKnot] += $VerticalDistance / [System.Math]::Abs($VerticalDistance)
                }
            }
            if ($KnotsY[$CurrentKnot] -gt $AnimationMaxY) { $AnimationMaxY = $KnotsY[$CurrentKnot]}
            if ($KnotsY[$CurrentKnot] -lt $AnimationMinY) { $AnimationMinY = $KnotsY[$CurrentKnot]}
            if ($KnotsX[$CurrentKnot] -lt $AnimationMinX) { $AnimationMinX = $KnotsX[$CurrentKnot]}
            if ($KnotsX[$CurrentKnot] -gt $AnimationMaxX) { $AnimationMaxX = $KnotsX[$CurrentKnot]}
        }
        $TailPositions["$($KnotsX[$CurrentKnot - 1]), $($KnotsY[$CurrentKnot - 1])"] += 1
        $AnimationFramesCount++
        $AnimationKnotPositions[$AnimationFramesCount] += @($KnotsX.ForEach{ $_ }, $KnotsY.ForEach{ $_ }, "Instruction: $HeadInstruction, $($HeadAmount - 1 - $HeadMove) more to go", "Unique TailPositionCount: $($TailPositions.Count) ")
    }
}

$AnimationGridWidth = $AnimationMaxX - $AnimationMinX + 1
$AnimationGridHeight = $AnimationMaxY - $AnimationMinY + 1
for ($AnimationFrame = 0; $AnimationFrame -lt $AnimationKnotPositions.Count; $AnimationFrame++) {
    if ($AnimationShowResultImmediately) { $AnimationFrame = $AnimationKnotPositions.Count - 1 }
    $grid = [object[]]::new($AnimationGridHeight)
    for ($AnimationCurrentGridLine = 0; $AnimationCurrentGridLine -lt $AnimationGridHeight; $AnimationCurrentGridLine++) {
        $grid[$AnimationCurrentGridLine] = @(" ") * $AnimationGridWidth
    }
    if ($AnimationShowTailTrail) {
        for ($AnimationMarkCheck = 0; $AnimationMarkCheck -lt $AnimationFrame; $AnimationMarkCheck++) {
            $TailX = $AnimationKnotPositions[$AnimationMarkCheck][0][$KnotsCount - 1] - $AnimationMinX
            $TailY = ($AnimationGridHeight - 1) - ($AnimationKnotPositions[$AnimationMarkCheck][1][$KnotsCount - 1] - $AnimationMinY)
            $grid[$TailY][$TailX] = "X"
        }
    }
    for ($AnimationKnotCounter = $KnotsCount - 1; $AnimationKnotCounter -ge 0; $AnimationKnotCounter--) {
        $KnotX = $AnimationKnotPositions[$AnimationFrame][0][$AnimationKnotCounter] - $AnimationMinX
        $KnotY = ($AnimationGridHeight - 1) - ($AnimationKnotPositions[$AnimationFrame][1][$AnimationKnotCounter] - $AnimationMinY)
        if ($AnimationFunny -and $AnimationKnotCounter -eq 0) {
            $grid[$KnotY][$KnotX] = "`u{1f432}" # Dirty hack to give the "head" a funny look. Takes 2 normal character widths to render
        } elseif ($AnimationFunny -and $AnimationKnotCounter -eq $KnotsCount - 1) {
            $grid[$KnotY][$KnotX] = "`u{27B0}" # Dirty hack to give the "tail" a funny look. Takes 2 normal character widths to render
        } elseif ($AnimationFunny) {
            $UniCodes = @("`u{1f534}", "`u{1f7e0}", "`u{1f7e1}", "`u{1f7e2}", "`u{1f535}", "`u{1f7e3}", "`u{1f7e4}", "`u{26ab}", "`u{26aa}")
            $grid[$KnotY][$KnotX] = $UniCodes[($AnimationKnotCounter - 1) % $UniCodes.Count] # Dirty hack to give the "body" a funny look. Takes 2 normal character widths to render
        } else {
            $grid[$KnotY][$KnotX] = $AnimationKnotCounter
        }
    }
    if ($AnimationMaxFPS -eq 0) { pause }
    if ($AnimationBlankScreen) { [System.Console]::Clear() }
    $grid.ForEach{ -join $_}
    if ($AnimationShowAnalysis) {
        Write-Output "Frame $AnimationFrame / $($AnimationKnotPositions.Count - 1)"
        Write-output "$($AnimationKnotPositions[$AnimationFrame][2])"
        Write-Output "$($AnimationKnotPositions[$AnimationFrame][3])"
        Write-Output "Press CTRL+C to stop immediately"
    }
    if ($null -ne $AnimationMaxFPS -and 0 -ne $AnimationMaxFPS) { Start-Sleep -Milliseconds (1000 / $AnimationMaxFPS) }
}

# $KnotsCount = 2 should give 13, ? (hopefully 88) and 6057
# $KnotsCount = 10 should give 1, 36 and 2514