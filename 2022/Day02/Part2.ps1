Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int] $Score = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

foreach ($Round in $Data) {
    $Opponent, $Me = $Round.Split(" ")
    switch ($Me) {
        "X" { # Lose. Scissors lose to Rock (A) and are worth 3 points. Rock loses to Paper (B) and is worth 1 point. Paper loses to Scissors and is worth 2 points
            $Score += 0
            if ($Opponent -eq "A") { $Score += 3 }
            elseif ($Opponent -eq "B") { $Score += 1 }
            elseif ($Opponent -eq "C") { $Score += 2 }
            break
        }
        "Y" { # Draw
            $Score += 3
            if ($Opponent -eq "A") { $Score += 1 }
            elseif ($Opponent -eq "B") { $Score += 2 }
            elseif ($Opponent -eq "C") { $Score += 3 }
            break
        }
        "Z" { # Win. Paper beats Rock (A) and is worth 2 points. Scissors beat Paper (B) and are worth 3 points. Rock beats Scissors and is worth 1 point
            $Score += 6
            if ($Opponent -eq "A") { $Score += 2 }
            elseif ($Opponent -eq "B") { $Score += 3 }
            elseif ($Opponent -eq "C") { $Score += 1 }
            break
        }
    }
}

Write-Host "$Score"
# Correct answer = 12316 (12 for testdata)