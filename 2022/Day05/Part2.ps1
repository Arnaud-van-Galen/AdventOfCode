Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -Raw -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -Raw -ErrorAction Stop

$DataStacks, $DataInstructions = $Data -split '(?:\r?\n){2,}'
$StacksUnparsed = $DataStacks.split([System.Environment]::NewLine)
$Stacks = [ordered] @{}
# Assumes StackNumbers and Letters begin at position "1", are 4 positions apart and are 1 character long
for ($StackColumn = 1; $StackColumn -lt $StacksUnparsed[0].Length; $StackColumn += 4) {
    $Stack = (-join $StacksUnparsed.ForEach{ $_[$StackColumn] }).Trim()
    $Stacks.Add( $Stack[-1].ToString(), -join $stack[-2..(-1 * $Stack.Length)] )
}
$Instructions = $DataInstructions.split([System.Environment]::NewLine)
foreach ($Instruction in $Instructions) {
    $Amount, $From, $To = $Instruction.split()[1,3,5]
    $Stacks[$To] += -join $Stacks[$From][(-1 * $Amount)..-1]
    $Stacks[$From] = $Stacks[$From].Substring(0, $Stacks[$From].Length - $Amount)
}

-join $Stacks.Values.ForEach{$_[-1]}
# Correct answer = BRQWDBBJM (MCD for testdata)