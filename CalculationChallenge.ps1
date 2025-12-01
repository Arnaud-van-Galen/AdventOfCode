# Initialize counters
$good = 0
$bad = 0
$total = 0

function Get-RandomChallenge {
    while ($true) {
        # Generate two random 3-digit numbers
        $num1 = Get-Random -Minimum 100 -Maximum 1000
        $num2 = Get-Random -Minimum 100 -Maximum 1000

        # Randomly choose addition or subtraction
        $operation = Get-Random -Minimum 0 -Maximum 2  # 0 for plus, 1 for minus

        if ($operation -eq 0) {
            $answer = $num1 + $num2
            $opChar = '+'
        } else {
            $answer = $num1 - $num2
            $opChar = '-'
        }

        # Check if the result is a three-digit number
        if ($answer -ge 100 -and $answer -le 999) {
            return @{ num1=$num1; num2=$num2; op=$opChar; answer=$answer }
        }
    }
}

while ($true) {
    $challenge = Get-RandomChallenge
    $prompt = "Wat is $($challenge.num1) $($challenge.op) $($challenge.num2)? (Typ 'STOP' om te stoppen): "
    
    $userInput = Read-Host $prompt

    if ($userInput.Trim().ToUpper() -eq "STOP") {
        Write-Host "Spel gestopt. Einde score:" -ForegroundColor Cyan
        Write-Host "Goed: $good | Fout: $bad | Totaal: $total"
        break
    }

    # Declare the variable before passing it by reference
    $userAnswer = 0

    # Try to parse input as int
    if ([int]::TryParse($userInput, [ref]$userAnswer)) {
        $total++

        if ($userAnswer -eq $challenge.answer) {
            $good++
            Write-Host "Correct!" -ForegroundColor Green
        } else {
            $bad++
            Write-Host "Fout. Het juiste antwoord was $($challenge.answer)." -ForegroundColor Red
        }
        Write-Host "Goed: $good | Fout: $bad | Totaal: $total`n"
    } else {
        Write-Host "Voer een geldig nummer in." -ForegroundColor Yellow
    }
}