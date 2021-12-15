Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$Lines = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
$Score1 = 0; $Scores2 = [int64[]]::new($Lines.Count)
for ($i = 0; $i -lt $Lines.Count; $i++) {
    while ((@("()","{}","[]","<>").ForEach{$Lines[$i].IndexOf($_)} | Measure-Object -Maximum).Maximum -ne -1) {
        $Lines[$i] = $Lines[$i].Replace("()","").Replace("{}","").Replace("[]","").Replace("<>","") }
    if ($Lines[$i].IndexOfAny(")}]>") -gt -1) {
        $Score1 += $Lines[$i][$Lines[$i].IndexOfAny(")}]>")].ToString().Replace(")",3).Replace("]",57).Replace("}",1197).Replace(">",25137)
    } else {
        for ($j = $Lines[$i].Length - 1; $j -ge 0; $j--) {
            $Scores2[$i] = 5 * $Scores2[$i] + $Lines[$i][$j].ToString().Replace("(",1).Replace("[",2).Replace("{",3).Replace("<",4) } } }
$Score1, ($Scores2.Where{$_ -ne 0} | Sort-Object)[(($Scores2.Where{$_ -ne 0}).Count -1) / 2]
# Correct answer = 294195, 3490802734 (26397, 288957 for testdata)