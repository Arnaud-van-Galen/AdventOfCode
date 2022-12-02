Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int] $Score = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

foreach ($Round in $Data) {
    $Opponent, $Me = $Round.Split(" ")
    switch ($Me) {
        "X" {   # Rock beats Scissors (C) and is worth 1 point
                $Score += 1
                if ($Opponent -eq "C") { $Score += 6 }
                elseif ($Opponent -eq "A") { $Score += 3}
                break
            }
        "Y" {   # Paper beats Rock (A) and is worth 2 points
                $Score += 2
                if ($Opponent -eq "A") { $Score += 6 }
                elseif ($Opponent -eq "B") { $Score += 3}
                break
        }
        "Z" {   # Scissors beats Paper (B) and is worth 3 points
                $Score += 3
                if ($Opponent -eq "B") { $Score += 6 }
                elseif ($Opponent -eq "C") { $Score += 3}
                break
        }
    }
}

Write-Host "$Score"
# Correct answer = 13809 (15 for testdata)