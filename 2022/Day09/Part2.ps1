Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

$TailPositions = @{"0, 0" = 1}
$KnotsCount = 10
$KnotsX = @(0) * $KnotsCount
$KnotsY = @(0) * $KnotsCount

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
# $Data = Get-Content -Path $PSScriptRoot\DataDemo2.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

foreach ($HeadInstruction in $Data) {
    $HeadDirection, $HeadAmount = $HeadInstruction.Split()
    for ($HeadMove = 0; $HeadMove -lt $HeadAmount; $HeadMove++) {
        $CurrentKnot = 0
        if ($HeadDirection -eq "U") { $KnotsY[$CurrentKnot]++ }
        elseif ($HeadDirection -eq "D") { $KnotsY[$CurrentKnot]-- }
        elseif ($HeadDirection -eq "L") { $KnotsX[$CurrentKnot]-- }
        elseif ($HeadDirection -eq "R") { $KnotsX[$CurrentKnot]++ }

        for ($CurrentKnot = 1; $CurrentKnot -lt $KnotsCount; $CurrentKnot++) {
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
        $TailPositions["$($KnotsX[$CurrentKnot - 1]), $($KnotsY[$CurrentKnot - 1])"] += 1
    }
}

$TailPositions.Count
# Correct answer = 2514 (1 and 36 for testdata)