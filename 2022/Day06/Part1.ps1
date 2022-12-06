Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int] $Distinctnumber = 4

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

for ($i = 0; $i -lt $Data.Length; $i++) {
    if (($Data[$i..($i + $Distinctnumber - 1)] | Select-Object -Unique).Count -eq $Distinctnumber) {
        $i + $Distinctnumber
        exit
    }
}
# Correct answer = 1544 (7 for testdata)