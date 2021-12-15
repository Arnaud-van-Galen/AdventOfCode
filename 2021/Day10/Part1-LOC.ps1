Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$Score1 = 0
foreach($Line in Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop) {
    while ((@("()","{}","[]","<>").ForEach{$Line.IndexOf($_)} | Measure-Object -Maximum).Maximum -ne -1) {
        $Line = $Line.Replace("()","").Replace("{}","").Replace("[]","").Replace("<>","") }
    if ($Line.IndexOfAny(")}]>") -gt -1) {
        $Score1 += $Line[$Line.IndexOfAny(")}]>")].ToString().Replace(")",3).Replace("]",57).Replace("}",1197).Replace(">",25137) } }
$Score1
# Correct answer = 294195 (26397 for testdata)