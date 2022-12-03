Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int] $MisplacedItemPrioritySum = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

foreach ($RugSackContent in $Data) {
    $itemsPerCompartment = $RugSackContent.Length / 2 
    $Compartment1 = $RugSackContent.Substring(0, $itemsPerCompartment)
    $Compartment2 = $RugSackContent.Substring($itemsPerCompartment, $itemsPerCompartment)
    $MisplacedItem = (Compare-Object $Compartment1.ToCharArray() $Compartment2.ToCharArray() -ExcludeDifferent).InputObject | Select-Object -Unique

    # a = 97 but gets score 1, A = 65 but gets score 27
    if ([byte]$MisplacedItem -ge 97) {
        $MisplacedItemPrioritySum += [byte]$MisplacedItem -97 + 1
    } else {
        $MisplacedItemPrioritySum += [byte]$MisplacedItem -65 + 27
    }
}

Write-Host "$MisplacedItemPrioritySum"
# Correct answer = 7997 (157 for testdata)