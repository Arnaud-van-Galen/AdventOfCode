(Get-Content -Path .\Data.txt | ForEach-Object { @("B X","C Y","A Z","A X","B Y","C Z","C X","A Y","B Z").IndexOf($_) + 1 } | Measure-Object -Sum).Sum
# Correct answer = 13809 (15 for testdata)