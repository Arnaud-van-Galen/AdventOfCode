Get-Variable | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

$Template = ""
$Rules = @{}
$PairCounts = @{}
$StepCount = 40

# $Manual = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Manual = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$Template = $Manual[0]
foreach ($Line in $Manual[2..$Manual.Count]) {
    $Key, $Value = $Line.Split(" -> ")
    $Rules.Add($Key, $Value)
}

# Store how often every pair occurs in the template
$TemplatePairs = [System.Collections.ArrayList] @()
for ($i = 0; $i -lt $Template.Length - 1; $i++) {
    $TemplatePairs.Add($Template.Substring($i, 2)) | Out-Null # Take 2 characters from Template
}
($TemplatePairs | Group-Object -NoElement).ForEach{$PairCounts.Add($_.Name, $_.Count)} # Store how often every pair occurs

for ($Step = 1; $Step -le $StepCount; $Step++) {
    $NewPolymerPairCount = @{}
    foreach ($Pair in $PairCounts.Keys) {
        #ToDo: I expected Add should be Add if not exist, otherwise += value, but the HashTable is smart enough to add a 0 valued key/value by default
        $NewPair1 = $Pair[0] + $rules[$Pair] # NN becomes NC...
        $NewPair2 = $rules[$Pair] + $Pair[1] # NN becomes ...and CN
        $NewPolymerPairCount[$NewPair1] += $PairCounts[$Pair]
        $NewPolymerPairCount[$NewPair2] += $PairCounts[$Pair]
    }
    $PairCounts = $NewPolymerPairCount
}

$Elements = @{}
foreach ($Pair in $PairCounts.Keys) {# DoubleCount all the Elements, except for the first and last in the Template
    $Elements[$Pair[0]] += $PairCounts[$Pair]
    $Elements[$Pair[1]] += $PairCounts[$Pair]
}
$Elements[$Template[0]]++ # Add 1 for the Template begin element
$Elements[$Template[-1]]++ # Add 1 for the Template end element

$AnalyseCount = $Elements.Values | Group-Object -NoElement | Measure-Object -Property Name -Maximum -Minimum
$AnalyseCount.Maximum / 2 - $AnalyseCount.Minimum / 2
# Correct answer = 1976896901756 (2188189693529 for testdata)