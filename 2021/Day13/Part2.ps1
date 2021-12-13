Get-Variable | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

$Dots = [System.Collections.ArrayList] @()
$Instructions = @()

# $FoldingManual = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$FoldingManual = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$InstructionType = 1
foreach ($Line in $FoldingManual) {
    if ($Line -eq "") { $InstructionType++ }
    elseif ($InstructionType -eq 1) { $Dots += $Line }
    elseif ($InstructionType -eq 2) { $Instructions += $Line }
}

foreach ($Instruction in $Instructions) {
    $Direction, [int] $Amount = $Instruction.Split(" =".ToCharArray())[-2,-1]
    for ($i = 0; $i -lt $Dots.Count; $i++) {
        [int] $CurrentX, [int] $CurrentY = $Dots[$i].Split(",")
        if ($Direction -eq "x" -and $Amount -lt $CurrentX) { # Transpose the right half to the left
            $NewX = $Amount - ($CurrentX - $Amount)
            $Dots[$i] = ($NewX, "," , $CurrentY | Join-String)
        } elseif ($Direction -eq "y" -and $Amount -lt $CurrentY) { # Transpose the bottom half to the top
            $NewY = $Amount - ($CurrentY - $Amount)
            $Dots[$i] = ($CurrentX, "," , $NewY | Join-String)
        } 
    }
    $Dots = $Dots | Select-Object -Unique
}

$Width = $Dots.ForEach{$_.Split(",")[0]} | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
$Height = $Dots.ForEach{$_.Split(",")[1]} | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
$Code = ""
for ($y = 0; $y -lt $Height; $y++) {
    for ($x = 0; $x -lt $Width; $x++) {
        if ($Dots.Contains( (($x, ",", $y) | Join-String))) {
            $Code += "*"
        } else {
            $Code += " "
        }
    }
    $Code += [System.Environment]::NewLine
}
$Code
# Correct answer = AHGCPGAI (17 for testdata)