Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

# https://regexr.com/
# https://docs.microsoft.com/en-us/dotnet/standard/base-types/regular-expression-language-quick-reference
# https://powershellexplained.com/2017-07-31-Powershell-regex-regular-expression/

# $HomeWork = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$HomeWork = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

# Adding
# [1,2] + [[3,4],5] becomes [[1,2],[[3,4],5]]
function Adding { param ( [string] $Pair1, [string] $Pair2 )
    # Write-Host "Added"
    return ("[", $Pair1, ",", $Pair2, "]" | Join-String)
}
# Adding -Pair1 "[1,2]" -Pair2 "[[3,4],5]"

# Exploding
# [[[[[9,8],1],2],3],4] becomes [[[[0,9],2],3],4]
# [7,[6,[5,[4,[3,2]]]]] becomes [7,[6,[5,[7,0]]]]
# [[6,[5,[4,[3,2]]]],1] becomes [[6,[5,[7,0]]],3]
# [[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]] becomes [[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]
# [[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]] becomes [[3,[2,[8,0]]],[9,[5,[7,0]]]].
function Exploding { param ( [string] $WholePairSet ) # Made it extra difficult for myself by allowing RegularNumbers to be > 9
    $Pairs = [Regex]::new('\[\d+,\d+\]').Matches($WholePairSet) # [1,2]
    $OpeningBraces = [Regex]::new('\[').Matches($WholePairSet) # [
    $ClosingBraces = [Regex]::new('\]').Matches($WholePairSet) # ]
    $RegularNumbers = [Regex]::new('\d+').Matches($WholePairSet) # [1,[ or ],2] # I used to select only non-paired numbers with (?!=\[)\d+(?=,\[)|(?<=\],)\d+(?=\])
    
    $ExplodablePairs = @()
    foreach($Pair in $Pairs) {
        $LeftOpeningBraces = $OpeningBraces.Where{$_.Index -lt $Pair.Index}
        $LeftClosingBraces = $ClosingBraces.Where{$_.Index -lt $Pair.Index}
        # Because the left [ of the Pair is included we should check for -ge 4 NOT -gt 4
        if ($LeftOpeningBraces.Count - $LeftClosingBraces.Count -ge 4) { # If any pair is nested inside four pairs...
            $ExplodablePairs += $Pair
        }
    }
    if ($ExplodablePairs.Count -ge 1) {
        $ExplodingPair = $ExplodablePairs[0] # ..., the leftmost such pair explodes.
        $PairLeftValue, $PairRightValue = [int[]] $ExplodingPair.Value.Split("[,]".ToCharArray(), [System.StringSplitOptions]::RemoveEmptyEntries)[0..1]
        
        $ReplaceRightPosition = ($RegularNumbers.Where{$_.Index -gt $ExplodingPair.Index + $ExplodingPair.Length} | Measure-Object -Property Index -Minimum).Minimum
        if ($ReplaceRightPosition) { # the pair's right value is added to the first regular number to the right of the exploding pair (if any)
            $ReplaceRegularNumber = $RegularNumbers.Where{$_.Index -eq $ReplaceRightPosition}
            $WholePairSet = $WholePairSet.Remove($ReplaceRegularNumber.Index, $ReplaceRegularNumber.Length)
            $WholePairSet = $WholePairSet.Insert($ReplaceRegularNumber.Index, $PairRightValue + $ReplaceRegularNumber.Value)
        }
        
        # the entire exploding pair is replaced with the regular number 0.
        $WholePairSet = $WholePairSet.Remove($ExplodingPair.Index, $ExplodingPair.Length)
        $WholePairSet = $WholePairSet.Insert($ExplodingPair.Index, 0)
        
        $ReplaceLeftPosition = ($RegularNumbers.Where{$_.Index -lt $ExplodingPair.Index} | Measure-Object -Property Index -Maximum).Maximum
        if ($ReplaceLeftPosition) { # the pair's left value is added to the first regular number to the left of the exploding pair (if any)
            $ReplaceRegularNumber = $RegularNumbers.Where{$_.Index -eq $ReplaceLeftPosition}
            $WholePairSet = $WholePairSet.Remove($ReplaceRegularNumber.Index, $ReplaceRegularNumber.Length)
            $WholePairSet = $WholePairSet.Insert($ReplaceRegularNumber.Index, $PairLeftValue + $ReplaceRegularNumber.Value)
        }
        # Write-Host "Exploded"
    } else {
        # Write-Host "Not Exploded"
    }
    return $WholePairSet
}
# Exploding -WholePairSet "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]"

function Splitting { param ( [string] $WholePairSet )
    $RegularNumbers = [Regex]::new('\d+').Matches($WholePairSet) # (?!=\[)\d+(?=,\[)|(?<=\],)\d+(?=\]) for [1,[ or ],2] but simply \d for all numbers

    $SplittableNumbers = $RegularNumbers.Where{$_.Value.Length -ge 2} # If any regular number is 10 or greater...
    if ($SplittableNumbers.Count -ge 1) {
        $SplittingNumber = $SplittableNumbers[0] #..., the leftmost such regular number splits.
        $PairLeftValue = [math]::Floor($SplittingNumber.Value / 2)
        $PairRightValue = [math]::Ceiling($SplittingNumber.Value / 2)
        # the entire splittable number is replaced with a pair of the splitted number.
        $WholePairSet = $WholePairSet.Remove($SplittingNumber.Index, $SplittingNumber.Length)
        $WholePairSet = $WholePairSet.Insert($SplittingNumber.Index, ("[", $PairLeftValue, ",", $PairRightValue, "]" | Join-String))
        # Write-Host "Splitted"
    } else {
        # Write-Host "Not Splitted"
    }
    return $WholePairSet
}
# Splitting -WholePairSet "[[3,[2,[18,10]]],[19,[5,[20,[30,2]]]]]"

function Magnitude { param ( [string] $WholePairSet )
    $Pairs = [Regex]::new('\[\d+,\d+\]').Matches($WholePairSet) # [1,2]
    
    for ($i = $Pairs.Count - 1; $i -ge 0; $i--) {
        $PairLeftValue, $PairRightValue = [int[]] $Pairs[$i].Value.Split("[,]".ToCharArray(), [System.StringSplitOptions]::RemoveEmptyEntries)[0..1]
        $PairMagnitude = $PairLeftValue * 3 + $PairRightValue * 2
        # the entire pair is replaced with its magnitude
        $WholePairSet = $WholePairSet.Remove($Pairs[$i].Index, $Pairs[$i].Length)
        $WholePairSet = $WholePairSet.Insert($Pairs[$i].Index, $PairMagnitude)
    }
    # if ($Pairs) {
    #     $WholePairSet = Magnitude -WholePairSet $WholePairSet
    # } else {
        return $WholePairSet 
    # }
}

$LargestMagnitude = 0
for ($i = 0; $i -lt $Homework.Count; $i++) {
    for ($j = 0; $j -lt $HomeWork.Count; $j++)  {
        if ($i -ne $j) {
            $Result = Adding -Pair1 $HomeWork[$i] -Pair2 $HomeWork[$j]
            $ReductionSteps = [System.Collections.Stack]::new()
            $ReductionSteps.Push("Explode")
            While ($ReductionSteps.Count -gt 0) {
                $Step = $ReductionSteps.Peek() 
                [void] $ReductionSteps.Pop()
                switch ($Step) {
                    "Explode" {
                        $ExplodeResult = Exploding -WholePairSet $Result
                        if ($ExplodeResult -ne $Result) {
                            $Result = $ExplodeResult
                            $ReductionSteps.Push("Explode")
                        } else {
                            $ReductionSteps.Push("Split")
                        }
                    }
                    "Split" {
                        $SplitResult = Splitting -WholePairSet $Result
                        if ($SplitResult -ne $Result) {
                            $Result = $SplitResult
                            $ReductionSteps.Push("Explode")
                        }      
                    }
                }
            }
            $WholePairSet = $Result
            while ([Regex]::new('\[\d+,\d+\]').Matches($WholePairSet)) {
                $WholePairSet = Magnitude -WholePairSet $WholePairSet
            }
            if ([int] $WholePairSet -gt $LargestMagnitude) {
                $LargestMagnitude = $WholePairSet
                Write-Host $i, $j, $LargestMagnitude, $HomeWork[$i], $HomeWork[$j]
            }
        }
    }
}

Write-Host "Het resultaat was:", $LargestMagnitude
# Correct answer = 4695 (3993 voor testdata)