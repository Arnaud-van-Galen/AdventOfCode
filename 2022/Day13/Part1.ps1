Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

class ValueList {
    [int] $DataSource
    [ListsAndIntegers[]] $TheChunks 
}

class ListsAndIntegers {
    [int] $BeginPosition
    [int] $EndPosition
    [int] $NextInterestingPosition
    [string] $TheChunk
}
function Get-ValueEndPosition { param ([string] $Value, [int] $BeginPosition )
    if ($Value.Substring($BeginPosition, 1) -eq "[") {
        $Opening, $Closing = 0, 0
        for ($i = $BeginPosition; $i -lt $Value.Length; $i++) {
            $char = $Value[$i]
            if ($char -eq "[") { $Opening++ }
            elseif ($char -eq "]") { $Closing++ }
            if ($Opening -le $Closing) { 
                return $i, $BeginPosition } 
        }
    } elseif ($Value.Substring($BeginPosition, 1) -in @(0..9)) {
        for ($i = $BeginPosition; $i -lt $Value.Length; $i++) {
            if ($Value.Substring($i, 1) -notin @(0..9)) { 
                return ($i -1), ($i -1) } 
        }
    }
    return $null
}

function Get-IsOrderCorrect { param ([ValueList] $ValueListLeft, [ValueList] $ValueListRight, [int] $LeftPosition, [int] $RightPosition)
    $CorrectOrder = $null

    while ($null -eq $CorrectOrder) {
	    $LeftChunk = ($ValueListLeft.TheChunks.where{$_.BeginPosition -ge $LeftPosition} | Sort-Object -Property BeginPosition)[0]##.foreach{$_}
	    $RightChunk = ($ValueListRight.TheChunks.where{$_.BeginPosition -ge $RightPosition} | Sort-Object -Property BeginPosition)[0]##.foreach{$_}
	    $ValueLeft = $LeftChunk.TheChunk
	    $ValueRight = $RightChunk.TheChunk
	    Write-Output "-$ValueLeft- vs -$ValueRight-"
	    if ($ValueLeft.StartsWith("[") -and $ValueRight.StartsWith("[")) { 
	        Write-Output "ListCompare"
            $LeftPosition++
            $RightPosition++
            Get-IsOrderCorrect -ValueListLeft $ValueListLeft -ValueListRight $ValueListRight -LeftPosition $LeftPosition -RightPosition $RightPosition
	    } elseif ($ValueLeft.StartsWith("[") -or $ValueRight.StartsWith("[")) { 
	        Write-Output "MixedCompare"
	        # if ($ValueLeft.StartsWith("[")) { $RightChunk.TheChunk = "[" + $RightChunk.TheChunk + "]" }
	        # elseif ($ValueRight.StartsWith("[")) { $LeftChunk.TheChunk = "[" + $LeftChunk.TheChunk + "]" }
            if ($ValueLeft.StartsWith("[")) {
                $ValueRight = "[" + $ValueRight + "]"
                $ValueListRight.TheChunks.Where{ $_.BeginPosition -eq $RightChunk.BeginPosition }.foreach{
                    $_.BeginPosition--
                    $_.EndPosition++
                    $_.NextInterestingPosition++
                    $_.TheChunk = "[" + $_.TheChunk + "]"
                }
                $ValueListRight.TheChunks.Where{ $_.BeginPosition -gt $RightChunk.BeginPosition }.foreach{
                    $_.BeginPosition += 2
                    $_.EndPosition += 2
                    $_.NextInterestingPosition += 2
                }
                $RightPosition = $RightChunk.BeginPosition
            } elseif ($ValueRight.StartsWith("[")) {
                $ValueLeft = "[" + $ValueLeft + "]"
                $ValueListLeft.TheChunks.Where{ $_.BeginPosition -eq $LeftChunk.BeginPosition }.foreach{
                    $_.BeginPosition--
                    $_.EndPosition++
                    $_.NextInterestingPosition++
                    $_.TheChunk = "[" + $_.TheChunk + "]"
                }
                $ValueListLeft.TheChunks.Where{ $_.BeginPosition -gt $LeftChunk.BeginPosition }.foreach{
                    $_.BeginPosition += 2
                    $_.EndPosition += 2
                    $_.NextInterestingPosition += 2
                }
                $LeftPosition = $LeftChunk.BeginPosition
            }
            Get-IsOrderCorrect -ValueListLeft $ValueListLeft -ValueListRight $ValueListRight -LeftPosition $LeftPosition -RightPosition $RightPosition
        } else {
	        Write-Output "IntegerCompare"
	        if ($ValueLeft -lt $ValueRight) { $CorrectOrder = $true}
	        elseif ($ValueLeft -gt $ValueRight) { $CorrectOrder = $false}
            $LeftPosition = $LeftChunk.EndPosition
            $RightPosition = $RightChunk.EndPosition
	    }
        $LeftPosition++
        $RightPosition++
        Write-Output "CorrectOrder: -$CorrectOrder-"
    }
    Write-Output "CorrectOrder: -$CorrectOrder-"
}

[string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
# [string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$ValueLists = [ValueList[]]::New($Data.Count) 
for ($i = 0; $i -lt $Data.Count; $i++) {
    if ($i % 3 -ne 2) { # Skip every third line
        $ValueList = [ValueList]::New()
        $ValueList.DataSource = $i
        $ValueList.TheChunks = @()
        for ($j = 0; $j -lt $Data[$i].Length; $j++) {
            $ValueEndPosition = Get-ValueEndPosition $Data[$i] $j
            if ($null -ne $ValueEndPosition) {
                $Chunk = [ListsAndIntegers]::New()
                $Chunk.BeginPosition = $j
                $Chunk.EndPosition = $ValueEndPosition[0]
                $Chunk.NextInterestingPosition = $ValueEndPosition[1]
                $Chunk.TheChunk = $($Data[$i].Substring($j, $ValueEndPosition[0] +1 -$j))
                $ValueList.TheChunks += $Chunk
                $j = $Chunk.NextInterestingPosition # Skip a few places for larger numbers (and maybe for ] and ,)
            }
        }
        $ValueLists[$i] = $ValueList
    }
}

for ($i = 0; $i -lt $ValueLists.Count; $i+=3) {
    if ($i -lt 6) {
        Get-IsOrderCorrect -ValueListLeft $ValueLists[$i] -ValueListRight $ValueLists[$i + 1] -LeftPosition 1 -RightPosition 1
    }
}

# Correct answer = ? (13 for testdata)

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds