[int]$GammaRate = 0
[int]$EpsilonRate = 0

#[string[]]$Report = "00100","11110","10110","10111","10101","01111","00111","11100","10000","11001","00010","01010"
[string[]]$Report=Get-Content .\03-1-Input.txt
[int]$DiagLength = ($Report[0]).Length

for ($i = 0 ; $i -lt $DiagLength ; $i++) {
    if (($Report | Where-Object {$_.substring($i, 1) -eq "1" }).Length / $Report.Length -gt 1/2) {
        $GammaRate += [math]::Pow(2, $DiagLength -1 -$i)
    } else {
        $EpsilonRate+=[math]::Pow(2, $DiagLength -1 -$i)
    }
}
Write-Host ($GammaRate * $EpsilonRate)
#Or don't calculate $EpsilonRate at all but just do Write-Host ($GammaRate * ([math]::Pow(2, $DiagLength) -1 -$GammaRate))