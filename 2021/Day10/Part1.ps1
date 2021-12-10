Get-Variable | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

function RemoveSimpleChunks { param ( [string] $StringToReduce )
    $new = $StringToReduce.Replace("()","").Replace("{}","").Replace("[]","").Replace("<>","")
    # no check needed to see if $new became "" because "all lines are corrupt"
    if ($new -ne $StringToReduce) { RemoveSimpleChunks -StringToReduce $new } else { return $new }
}
[int] $Points = 0

[string[]] $Lines = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
# [string[]] $Lines = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$Lines.ForEach{
    $Reduced = RemoveSimpleChunks -StringToReduce $_
    $WrongClosurePosition = $Reduced.IndexOfAny(")}]>")
    if ($WrongClosurePosition -gt -1) {
        switch ($Reduced[$WrongClosurePosition]) {
            ")" { $Points += 3 ; break }
            "]" { $Points += 57 ; break }
            "}" { $Points += 1197 ; break }
            ">" { $Points += 25137 ; break }
        }
        # Write-Host $_, $Reduced, $Reduced[$WrongClosurePosition]
    }
}

$Points
# Correct answer = 294195 (26397 for testdata)