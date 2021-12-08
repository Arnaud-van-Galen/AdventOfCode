Get-Variable | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[System.Collections.ArrayList] $BingoCards = @()
[string[]] $BingoOrder = @()
[int] $BingoSize = 0
$Bingo = $false

# [string[]] $BingoInput = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $BingoInput = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

for ($i = 1 ; $i -lt $BingoInput.Count ; $i++) {
    if ($BingoInput[$i] -eq "") {
        $BingoCards.Add( [string[]] @() ) | Out-Null
    } else {
        $BingoCards[-1] += $BingoInput[$i].Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)
    }
}

$BingoOrder = $BingoInput[0].Split(",")
$BingoSize = [math]::Sqrt($BingoCards[0].Count)
foreach ($BingoCallNumber in $BingoOrder) {
    foreach ($BingoCard in $BingoCards) {
        # All fields in the BingoCard should have a value 0 and up.
        # If the number is Drawn/Hit the value will be set to -1 and Bingo happens when all fields in a row or column become -1
        # After Bingo on a card all fields are emptied so the card will not have to be checked again 
        if ($BingoCard[0]) {
            $HitIndex = $BingoCard.IndexOf($BingoCallNumber)
            if ($HitIndex -ge 0) {
                $BingoCard[$HitIndex] = -1
                $HitRow = [Math]::Floor($HitIndex / $BingoSize)
                $HitColumn = $HitIndex % $BingoSize
                $HitRowSum = ($BingoCard[($HitRow * $BingoSize)..((($HitRow + 1) * $BingoSize) -1)] | Measure-Object -Sum).Sum
                if ($HitRowSum + $BingoSize -eq 0) { $Bingo = $true }
                [int] $HitColumnSum = 0
                for ($i = 0 ; $i -lt $BingoCard.Count ; $i++) {
                    if ($i % $BingoSize -eq $HitColumn) { $HitColumnSum += $BingoCard[$i] }
                }
                # ToDo: Improve the above loop for calculating HitColumnSum with Object.Where like $BingoCard.Where({ $_.Rank % $BingoSize -eq $HitColumn })
                if ($HitColumnSum + $BingoSize -eq 0) { $Bingo = $true }
                if ($Bingo) {
                    Write-Host "Bingo on Card $BingoCard after $BingoCallNumber"
                    ($BingoCard.where({$_ -ne -1}) | Measure-Object -Sum).Sum * $BingoCallNumber
                    # Correct answer = 21070 (1924 for testdata)
                    $BingoCard.Clear()
                    $Bingo = $false
                }
            }
        }
    }
}