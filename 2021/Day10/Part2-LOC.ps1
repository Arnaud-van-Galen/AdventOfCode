Get-Variable | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$Lines = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
$Scores2 = [int64[]]::new($Lines.Count)
for ($i = 0; $i -lt $Lines.Count; $i++) {
    while ((@("()","{}","[]","<>").ForEach{$Lines[$i].IndexOf($_)} | Measure-Object -Maximum).Maximum -ne -1) {
        $Lines[$i] = $Lines[$i].Replace("()","").Replace("{}","").Replace("[]","").Replace("<>","") }
    if ($Lines[$i].IndexOfAny(")}]>") -eq -1) {
        for ($j = $Lines[$i].Length - 1; $j -ge 0; $j--) {
            $Scores2[$i] = 5 * $Scores2[$i] + $Lines[$i][$j].ToString().Replace("(",1).Replace("[",2).Replace("{",3).Replace("<",4) } } }
($Scores2.Where{$_ -ne 0} | Sort-Object)[(($Scores2.Where{$_ -ne 0}).Count -1) / 2]
# Correct answer = 3490802734 (288957 for testdata)