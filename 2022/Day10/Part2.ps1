Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

$Cycle = 0
$X = 1
$CycleValues = @{ $Cycle = $X }
$ScreenWidth = 40
$Animate = $false

# $Data = Get-Content -Path $PSScriptRoot\DataDemo2.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

foreach ($Instruction in $Data) {
    $Cycle++
    $CycleValues[$Cycle] += $X
    if ($Instruction.Split()[0] -eq "addx") {
        $Cycle++
        $X += $Instruction.Split()[1]
        $CycleValues[$Cycle] += $X
    }
}

$CRT = ""
for ($CycleValue = 1; $CycleValue -lt $CycleValues.Count; $CycleValue++) {
    $SpriteCenter = $CycleValues[$CycleValue - 1] # During Cycle X we have to use the previous CycleValue
    $Sprites = @(($SpriteCenter - 1)..($SpriteCenter + 1)) # Sprites go from 0 to 39.Where{ $_ -in @(0..($ScreenWidth - 1)) }
    if (($CycleValue - 1) % $ScreenWidth -in $Sprites) { # Cycles go from 1 to 40 so subtract 1 and mod 40 to map them
        if (!$Animate) { $CRT += "#" } else { $CRT += "`u{1f7e5}" }
    } else {
        if (!$Animate) { $CRT += "." } else { $CRT += "`u{2b1c}" }
    }
    if ($CycleValue % $ScreenWidth -eq 0) {
        $CRT += [System.Environment]::NewLine
    }
    if ($Animate) {
        [System.Console]::Clear()
        $CRT
        Start-Sleep -Milliseconds 25
    }
}
if (!$Animate) { $CRT }

# Correct answer = PLULKBZH (2-7 on, 2-7 off for testdata)