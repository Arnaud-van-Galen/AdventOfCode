(Get-Content -Path .\Data.txt | ForEach-Object { @("B X","C X","A X","A Y","B Y","C Y","C Z","A Z","B Z").IndexOf($_) + 1 } | Measure-Object -Sum).Sum
# Correct answer = 12316 (12 for testdata)