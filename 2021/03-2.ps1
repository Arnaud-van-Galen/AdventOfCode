# [string[]] $Report = "00100","11110","10110","10111","10101","01111","00111","11100","10000","11001","00010","01010"
[string[]] $Report = Get-Content .\03-1-Input.txt

function Find-MostCommonOrMatching { param( [string] $findvalue, [string[]] $report )
    for ($i = 0 ; $i -lt $report[0].Length ; $i++) {
        [string[]] $workingReport = $report | Where-Object { $_.substring($i, 1) -eq $findvalue }
        if ($findvalue -eq "1") {
            if ($workingReport.Count / $report.Count -lt 1/2) {
                $workingReport = Compare-Object $report $workingReport -PassThru
            }
        } else {
            if ($workingReport.Count / $report.Count -gt 1/2) {
                $workingReport = Compare-Object $report $workingReport -PassThru
            }
        }
        $report = $workingReport
        # Write-Host $i, $report
        if ($report.Count -eq 1) { return [Convert]::ToInt32($report, 2) }
    }
}

$OxygenGeneratorRating = Find-MostCommonOrMatching -findvalue "1" -report $Report
$CO2ScrubberRating = Find-MostCommonOrMatching -findvalue "0" -report $Report

Write-Host ($OxygenGeneratorRating * $CO2ScrubberRating)
# Correct answer = 2372923