#[string[]]$Report = "00100","11110","10110","10111","10101","01111","00111","11100","10000","11001","00010","01010"
[string[]]$Report=Get-Content .\03-1-Input.txt
[int]$DiagLength = ($Report[0]).Length

#Not happy with all the "if ($findvalue) and "if (!$findvalue)" but it was needed for the -gt vs -ge and to avoid writing seperate Find-MostCommon and Find-LeastCommon functions
function Find-Common {param([int]$findvalue, $report)
    for ($i = 0 ; $i -lt $DiagLength ; $i++) {
        [string[]]$workingReport = $report | Where-Object {$_.substring($i, 1) -eq $findvalue }
        if ((!$findvalue -and $workingReport.Length / $report.Length -gt 1/2) -or ($findvalue -and $workingReport.Length / $report.Length -ge 1/2)) {
            if (!$findvalue) { $workingReport = $report | Where-Object {$_ -notin $workingReport} }
            #Write-Host "keeping 1"
        } else {
            if ($findvalue) { $workingReport = $report | Where-Object {$_ -notin $workingReport} }
            #Write-Host "keeping 0"
        }
        $report = $workingReport
        #Write-Host $i, $report
        if ($report.Length -eq 1) { return [Convert]::ToInt32($report,2)}
    }
}

$OxygenGeneratorRating = Find-Common -findvalue 1 -report $Report
$CO2ScrubberRating = Find-Common -findvalue 0 -report $Report
Write-Host ($OxygenGeneratorRating * $CO2ScrubberRating)