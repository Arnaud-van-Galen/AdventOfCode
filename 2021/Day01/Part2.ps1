Get-Variable | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int] $PrevReportValue = $NULL
[int] $IncreaseCount = 0
[int] $GroupSize = 3

# $Report = 199,200,208,210,200,207,240,269,260,263
$Report = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

for ($i = $GroupSize ; $i -lt $Report.Count ; $i++) {
    if (!$PrevReportValue) { $PrevReportValue = $Report[ ($i-$GroupSize)..($i-1) ] | Measure-Object -Sum | Select-Object -expand Sum }
    $ReportValue = $Report[ ($i-$GroupSize+1)..($i) ] | Measure-Object -Sum | Select-Object -expand Sum
    if ($PrevReportValue -lt $ReportValue) {
        # Write-Host "From $PrevReportValue to $ReportValue is an increase"
        $IncreaseCount++
    }
    $PrevReportValue = $ReportValue
}

Write-Host "The number of times a depth measurement increases: $IncreaseCount"
# Correct answer = 1518 (5 for testdata)