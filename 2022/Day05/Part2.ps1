Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -Raw -ErrorAction Stop
# $Stacks = @("".ToCharArray(), "ZN".ToCharArray(), "MCD".ToCharArray(), "P".ToCharArray()) # ToDo, get this from code
$Data = Get-Content -Path $PSScriptRoot\Data.txt -Raw -ErrorAction Stop
$Stacks = @("".ToCharArray(), "SMRNWJVT".ToCharArray(), "BWDJQPCV".ToCharArray(), "BJFHDRP".ToCharArray(), "FRPBMND".ToCharArray(), "HVRPTB".ToCharArray(), "CBPT".ToCharArray(), "BJRPL".ToCharArray(), "NCSLTZBW".ToCharArray(), "LSG".ToCharArray()) # ToDo, get this from code

$DataStacks, $DataInstructions = $Data -split '(?:\r?\n){2,}'
$Instructions = $DataInstructions.split([System.Environment]::NewLine)
foreach ($Instruction in $Instructions) {
    $Amount, $From, $To = $Instruction.split()[1,3,5]
    $MoveStack = $Stacks[$From][(-1 * $Amount)..-1]
    $Stacks[$To] += $MoveStack
    if ($Stacks[$From].Length -gt $Amount) {
        $Stacks[$From] = $Stacks[$From][0..($Stacks[$From].Length - $Amount -1 )]
    } else {
        $Stacks[$From] = @()
    }

}

-join $Stacks.ForEach{$_[-1]}
# Correct answer = BRQWDBBJM (MCD for testdata)