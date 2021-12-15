Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

function RemoveSimpleChunks { param ( [string] $StringToReduce )
    $new = $StringToReduce.Replace("()","").Replace("{}","").Replace("[]","").Replace("<>","")
    # no check needed to see if $new became "" because "all lines are corrupt"
    if ($new -ne $StringToReduce) { RemoveSimpleChunks -StringToReduce $new } else { return $new }
}
[int64[]] $Scores = @()

# [string[]] $Lines = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $Lines = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$Lines.ForEach{
    $Reduced = RemoveSimpleChunks -StringToReduce $_
    $WrongClosurePosition = $Reduced.IndexOfAny(")}]>")
    if ($WrongClosurePosition -eq -1) {
        $CompleteNeeded = $Reduced.ToCharArray()
        [array]::Reverse($CompleteNeeded)
        $CompleteNeeded = ((-join $CompleteNeeded).Replace("(",")").Replace("{","}").Replace("[","]").Replace("<",">")).ToCharArray()
        [int64] $Score = 0
        $CompleteNeeded.ForEach{
            $Score *= 5
            switch ($_) {
                ")" { $Score += 1 ; break }
                "]" { $Score += 2 ; break }
                "}" { $Score += 3 ; break }
                ">" { $Score += 4 ; break }
            }
        }
        # Write-Host $_, $Reduced, $CompleteNeeded, $Score
        $Scores += $Score
    }
}

($Scores | Sort-Object)[($Scores.Count -1) / 2]
# Correct answer = 3490802734 (288957 for testdata)