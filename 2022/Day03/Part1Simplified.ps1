Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int] $MisplacedItemPrioritySum = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

foreach ($RugSackContent in $Data) {
    $itemsPerCompartment = $RugSackContent.Length / 2 
    $Compartment1 = $RugSackContent[0..($itemsPerCompartment - 1)]
    $Compartment2 = $RugSackContent[$itemsPerCompartment..($RugSackContent.Length - 1)]
    $MisplacedItem = $Compartment1.ForEach{ $Compartment2 -ceq $_ } | Select-Object -Unique
    $MisplacedItemPrioritySum += " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".IndexOf($MisplacedItem)
}

Write-Host "$MisplacedItemPrioritySum"
# Correct answer = 7997 (157 for testdata)