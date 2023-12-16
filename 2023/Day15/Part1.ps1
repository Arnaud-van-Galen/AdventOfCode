Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[int] $Result = 0

# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
$Sequences = $Data.Split(',')
$Sequences.ForEach{
    $SequenceChars = $_.ToCharArray()
    $CurrentValue = 0
    $SequenceChars.ForEach{
        $ASCII = [byte]$_
        $CurrentValue += $ASCII
        $CurrentValue *= 17
        $CurrentValue = $CurrentValue % 256
    }
    $Result += $CurrentValue
}


Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 505379 (1320 for testdata)