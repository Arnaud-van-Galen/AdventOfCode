Get-Variable | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int] $GammaRate = 0
[int] $EpsilonRate = 0

# [string[]] $Report = "00100","11110","10110","10111","10101","01111","00111","11100","10000","11001","00010","01010"
[string[]] $Report = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

[int] $DiagLength = $Report[0].Length
for ($i = 0 ; $i -lt $DiagLength ; $i++) {
    if ( ($Report.Substring($i, 1) | Measure-Object -Average).Average -gt 1/2) {
        $GammaRate += [math]::Pow(2, $DiagLength -1 -$i)
    } else {
        $EpsilonRate += [math]::Pow(2, $DiagLength -1 -$i)
    }
}

Write-Host ($GammaRate * $EpsilonRate)
# Correct answer = 749376 (198 for testdata)

# Or don't calculate $EpsilonRate at all but just do Write-Host ($GammaRate * ([math]::Pow(2, $DiagLength) -1 -$GammaRate))