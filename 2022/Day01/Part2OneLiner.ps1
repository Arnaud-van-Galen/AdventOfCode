(((Get-Content -Path .\Data.txt -Raw) -split '(?:\r?\n){2,}').ForEach{$_ -split "\r" | Measure-Object -Sum | Select-Object -ExpandProperty Sum} | Sort-Object -Descending)[0..2] | Measure-Object -Sum | Select-Object -ExpandProperty Sum
# Correct answer = 207576 (45000 for testdata)