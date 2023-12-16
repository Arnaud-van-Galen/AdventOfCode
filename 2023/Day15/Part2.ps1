Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0
$Boxes=@()
@(0..255).ForEach{$Boxes +=[ordered]@{}}

# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$Sequences = $Data.Split(',')
$Sequences.ForEach{
    $Label, $Operation, $FocalLength = [regex]::Matches($_,'(.*)([=-])(.*)').Groups[1..3].Value
    $SequenceChars = $Label.ToCharArray()
    $CurrentValue = 0
    $SequenceChars.ForEach{
        $ASCII = [byte]$_
        $CurrentValue += $ASCII
        $CurrentValue *= 17
        $CurrentValue = $CurrentValue % 256
    }
    if ($Operation -eq '-') {
        $Boxes[$CurrentValue].Remove($Label)
    } else {
        $Boxes[$CurrentValue][$Label] = $FocalLength
    }
}

for ($i = 0; $i -lt $Boxes.Count; $i++) {
    if ($Boxes[$i].Count -ne 0) {
        for ($lenses = 0; $lenses -lt $Boxes[$i].Count; $lenses++) {
            $Result += ($i+1) * ($lenses+1) * $Boxes[$i][$lenses]
        }
    }
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 263211 (145 for testdata)