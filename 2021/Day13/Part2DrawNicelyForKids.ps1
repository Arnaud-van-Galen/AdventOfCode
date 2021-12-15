Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

$Dots = [System.Collections.ArrayList] @()
$Instructions = @()
$MaxDrawSize = 450 # Everything bigger than 450 is VERY slow to draw, 900 will show everything
function Draw {  param ( [string] $Direction, [int] $Amount, [bool] $Last )
    $Width = $Dots.ForEach{$_.Split(",")[0]} | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
    $Height = $Dots.ForEach{$_.Split(",")[1]} | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
    if ($Width -lt $MaxDrawSize -and $Height -lt $MaxDrawSize) {
            $Code = [System.Text.StringBuilder]::new()
            for ($y = 0; $y -le $Height; $y++) {
                for ($x = 0; $x -le $Width; $x++) {
                    if ($Direction -eq "x" -and $x -eq $Amount -and !$Last) { [void]$Code.Append("`u{1f64f}")} # `u{2b1b} for scissors, 1f64f for hands, 2702 for black
                    elseif ($Direction -eq "y" -and $y -eq $Amount -and !$Last ) { [void]$Code.Append("`u{1f64f}")}
                    elseif ($Dots.Contains( (($x, ",", $y) | Join-String))) {
                        [void]$Code.Append("`u{1f7e5}") # https://unicode.org/emoji/charts/full-emoji-list.html#1f7e5
                    } else {
                        [void]$Code.Append("`u{2b1c}") # https://unicode.org/emoji/charts/full-emoji-list.html#2b1c
                    }
                }
                [void]$Code.Append([System.Environment]::NewLine)
            }
        $Code.ToString()
        # Correct answer = AHGCPGAU
        $Richting = if ($Direction -eq "x") {"horizontaal", "kolom"} else {"verticaal","rij"}
        if (!$Last) {
            Write-Host "Voor Alex en Amie: Vouw $($Richting[0]) op $($Richting[1]) $($Amount)" 
            Start-Sleep -Seconds 5
            [System.Console]::Clear()
        } else {
            Write-Host "Zien jullie de geheime code?"
         }
    } else {
        Write-Host "This paper is still too large ($($Width) by $($Height)) to draw, fold it a few more times until the size is less then $($MaxDrawSize)"
    }
}

# $FoldingManual = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$FoldingManual = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$InstructionType = 1
foreach ($Line in $FoldingManual) {
    if ($Line -eq "") { $InstructionType++ }
    elseif ($InstructionType -eq 1) { $Dots += $Line }
    elseif ($InstructionType -eq 2) { $Instructions += $Line }
}

for ($Instruction = 0; $Instruction -lt $Instructions.Count; $Instruction++) {
    $Direction, [int] $Amount = $Instructions[$Instruction].Split(" =".ToCharArray())[-2,-1]
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
    if ($Instruction -lt $Instructions.Count - 1) {
        $Direction, [int] $Amount = $Instructions[$Instruction + 1].Split(" =".ToCharArray())[-2,-1]
        Draw -Direction $Direction -Amount $Amount
    } else {
        Draw -Direction "None" -Amount 0 -Last $True
    }
}