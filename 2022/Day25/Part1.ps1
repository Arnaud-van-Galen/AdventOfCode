Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

$SNAFUTotal = 0

function SnafuToDecimal { param ( [string] $SNAFU )
    $SNAFU = $SNAFU.Trim()
    [int64] $Decimal = 0
    for ($i = 0; $i -lt $SNAFU.Length; $i++) {
        $SNAFUDigit = $SNAFU.Substring($SNAFU.Length -1 - $i, 1)
        if ($SNAFUDigit -eq "=") { $SNAFUDigit = -2 }
        elseif ($SNAFUDigit -eq "-") { $SNAFUDigit = -1 }
        $SNAFUDigitValue = [System.Math]::Pow(5, $i) * $SNAFUDigit
        $Decimal += $SNAFUDigitValue
    }
    return $Decimal
}
function DecimalToSnafu { param ( [int64] $Decimal )
    [string] $SNAFU = ""
    while ($Decimal -gt 0) {
        $SNAFUDigit = $Decimal % 5
        $Decimal = [System.math]::Floor($Decimal / 5)
        if ($SNAFUDigit -eq "3") { $SNAFUDigit = "="; $Decimal += 1 }
        elseif ($SNAFUDigit -eq "4") { $SNAFUDigit = "-" ; $Decimal += 1}
        $SNAFU = $SNAFUDigit.ToString() + $SNAFU
    }
    return $SNAFU
}

# [string[]] $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
[string[]] $Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

foreach ($SNAFULine in $Data) {
    $SNAFUTotal += SnafuToDecimal -SNAFU $SNAFULine
}
DecimalToSnafu -Decimal $SNAFUTotal

# Correct answer = 20-==01-2-=1-2---1-0 (2=-1=0 for testdata)

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds