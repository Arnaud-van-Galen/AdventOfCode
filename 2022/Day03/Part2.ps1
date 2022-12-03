Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int] $BadgePrioritySum = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$GroupSize = 3
for ($i = 0; $i -lt $Data.Count; $i += $GroupSize) {
    $GroupData = $Data[$i..($GroupSize +$i - 1)]
    $UniqueInGroup = $GroupData[0].ToCharArray() | Select-Object -Unique
    for ($j = 1; $j -lt $GroupData.Count; $j++) {
        $UniqueInGroup = (Compare-Object $UniqueInGroup $GroupData[$j].ToCharArray() -ExcludeDifferent).InputObject | Select-Object -Unique
    }
    
    # a = 97 but gets score 1, A = 65 but gets score 27
    if ([byte]$UniqueInGroup -ge 97) {
         $BadgePrioritySum += [byte]$UniqueInGroup -97 + 1
    } else {
        $BadgePrioritySum += [byte]$UniqueInGroup -65 + 27
    }
}

Write-Host "$BadgePrioritySum"
# Correct answer = 2545 (70 for testdata)