Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int] $PrevReportValue = $NULL
[int] $IncreaseCount = 0

# $Report = 199,200,208,210,200,207,240,269,260,263
$Report = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

foreach ($ReportValue in $Report) {
    if ($PrevReportValue -and $PrevReportValue -lt $ReportValue) {
        # Write-Host "From $PrevReportValue to $ReportValue is an increase"
        $IncreaseCount++
    }
    $PrevReportValue = $ReportValue
}

Write-Host "The number of times a depth measurement increases: $IncreaseCount"
# Correct answer = 1482 (7 for testdata)