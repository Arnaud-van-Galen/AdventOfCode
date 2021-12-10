Get-Variable | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
[int64[]] $Scores = @()
foreach($Line in Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop) {
    while ((@("()","{}","[]","<>").ForEach({$Line.IndexOf($_)}) | Measure-Object -Maximum).Maximum -ne -1) {
        $Line = $Line.Replace("()","").Replace("{}","").Replace("[]","").Replace("<>","") }
    if ($Line.IndexOfAny(")}]>") -eq -1) {
        $CompleteNeeded = $Line.ToCharArray()
        [array]::Reverse($CompleteNeeded)
        [int64] $Score = 0
        foreach ($CompleteValue in $(-join $CompleteNeeded).Replace("(",1).Replace("[",2).Replace("{",3).Replace("<",4).ToCharArray()) {
            $Score = 5 * $Score + $CompleteValue.ToString() }
        $Scores += $Score } }
($Scores | Sort-Object)[($Scores.Count -1) / 2]
# Correct answer = 3490802734 (288957 for testdata)