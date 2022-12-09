Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

$TailPositions = @{"0, 0" = 1}
$HeadX, $HeadY, $TailX, $TailY = 0, 0, 0, 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

foreach ($HeadInstruction in $Data) {
    $HeadDirection, $HeadAmount = $HeadInstruction.Split()
    for ($HeadMove = 0; $HeadMove -lt $HeadAmount; $HeadMove++) {
        if ($HeadDirection -eq "U") { $HeadY++ }
        elseif ($HeadDirection -eq "D") { $HeadY-- }
        elseif ($HeadDirection -eq "L") { $HeadX-- }
        elseif ($HeadDirection -eq "R") { $HeadX++ }
        
        $HorizontalDistance = $HeadX - $TailX
        $VerticalDistance = $HeadY - $TailY
        $IsDiagonal = ($HeadX -ne $TailX -and $HeadY -ne $TailY)
        if ($IsDiagonal -and ([System.Math]::Abs($HorizontalDistance) -eq 2 -or [System.Math]::Abs($VerticalDistance) -eq 2)) { # Move diagonally
            $TailX += $HorizontalDistance / [System.Math]::Abs($HorizontalDistance)
            $TailY += $VerticalDistance / [System.Math]::Abs($VerticalDistance)
        } elseif ([System.Math]::Abs($HorizontalDistance) -eq 2) {
            $TailX += $HorizontalDistance / [System.Math]::Abs($HorizontalDistance)
        } elseif ([System.Math]::Abs($VerticalDistance) -eq 2) {
            $TailY += $VerticalDistance / [System.Math]::Abs($VerticalDistance)
        }
        $TailPositions["$TailX, $TailY"] += 1
    }
}

$TailPositions.Count
# Correct answer = 6057 (13 for testdata)