Get-Variable | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

$Template = ""
$Rules = @{}
$StepCount = 10

# $Manual = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Manual = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$Template = $Manual[0]
foreach ($Line in $Manual[2..$Manual.Count]) {
    $Key, $Value = $Line.Split(" -> ")
    $Rules.Add($Key, $Value)
}

for ($Step = 1; $Step -le $StepCount; $Step++) {
    $NewPolymer = [System.Collections.ArrayList] @()
    for ($i = 0; $i -lt $Template.Length - 1; $i++) {
        $TemplatePair = $Template.Substring($i, 2) # Take 2 characters from Template in this step
        $NewPolymer.Add($TemplatePair[0] + $Rules[$TemplatePair]) | Out-Null # TempArray += Add the first character of that and the looked up InsertionElement
        # Write-Host $Template, $TemplatePair, $Rules[$TemplatePair], $NewPolymer
    }
    $Template = ($NewPolymer | Join-String) + $Template[-1] # The new Template becomes the TempArray and the last character of the old Template
}

$AnalyseCount = $Template.ToCharArray() | Group-Object -NoElement | Measure-Object -Property Count -Maximum -Minimum
$AnalyseCount.Maximum - $AnalyseCount.Minimum
# Correct answer = 2375 (1588 for testdata)