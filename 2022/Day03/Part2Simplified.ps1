Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int] $BadgePrioritySum = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

for ($i = 0; $i -lt $Data.Count; $i += 3) {
    $GroupData = $Data[$i..($i + 2)]
    $UniqueInGroup = ($GroupData[0].ToCharArray().ForEach{ $GroupData[1].ToCharArray() -ceq $_ }).ForEach{ $GroupData[2].ToCharArray() -ceq $_ } | Select-Object -Unique
    $BadgePrioritySum += " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".IndexOf($UniqueInGroup)
}

Write-Host "$BadgePrioritySum"
# Correct answer = 2545 (70 for testdata)