Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

class Monkey {
    [int[]] $WorryLevels
    [string] $OperationKind
    [string] $OperationAmount
    [int] $TestValue
    [int] $TestPassMonkeyID
    [int] $TestFailMonkeyID
    [int] $InSpectionCount = 0
}
$Rounds = 10000
$LeastCommonMultiple = 1 # Going to fake this

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -Raw -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -Raw -ErrorAction Stop

$DataMonkeys = $Data -split '(?:\r?\n){2,}'
$Monkeys = [Monkey[]]::new($DataMonkeys.Count)

foreach ($DataMonkey in $DataMonkeys) {
    $CurrentDataMonkey = $DataMonkey.Split([System.Environment]::NewLine)
    # ParseAction: Turn '     Monkey 0:' into 0
    $MonkeyID = $CurrentDataMonkey[0].Split(" :".ToCharArray())[1]
    $Monkeys[$MonkeyID] = [Monkey]::new()
    $CurrentMonkey = $Monkeys[$MonkeyID]
    # ParseAction: Turn '   Starting items: 79, 98' into @(79, 98)
    $CurrentMonkey.WorryLevels = $CurrentDataMonkey[1].Split(": ")[1].Split(", ")
    # ParseAction: Turn '   Operation: new = old * 19' into * and 19
    $CurrentMonkey.OperationKind, $CurrentMonkey.OperationAmount = $CurrentDataMonkey[2].Split(": ")[1].Split(" ")[-2..-1]
    # ParseAction: Turn '   Test: divisible by 23' into 23
    $CurrentMonkey.TestValue = $CurrentDataMonkey[3].Split(" ")[-1]
    $LeastCommonMultiple = $LeastCommonMultiple * $CurrentMonkey.TestValue
    # ParseAction: Turn '     If true: throw to monkey 2' into 2
    $CurrentMonkey.TestPassMonkeyID = $CurrentDataMonkey[4].Split(" ")[-1]
    # ParseAction: Turn '     If false: throw to monkey 3' into 3
    $CurrentMonkey.TestFailMonkeyID = $CurrentDataMonkey[5].Split(" ")[-1]
}

for ($Round = 0; $Round -lt $Rounds; $Round++) {
    for ($CurrentMonkeyID = 0; $CurrentMonkeyID -lt $Monkeys.Count; $CurrentMonkeyID++) {
        $CurrentMonkey = $Monkeys[$CurrentMonkeyID]
        for ($CurrentWorryLevelIndex = 0; $CurrentWorryLevelIndex -lt $CurrentMonkey.WorryLevels.Count; $CurrentWorryLevelIndex++) {
            $CurrentWorryLevel = $CurrentMonkey.WorryLevels[$CurrentWorryLevelIndex]
            $WorryLevelChange = $CurrentMonkey.OperationAmount
            if ($CurrentMonkey.OperationAmount -eq "old") { $WorryLevelChange = $CurrentWorryLevel }
            if ($CurrentMonkey.OperationKind -eq "*") {
                $CurrentWorryLevel = $CurrentWorryLevel * $WorryLevelChange
            } else {
                $CurrentWorryLevel = $CurrentWorryLevel + $WorryLevelChange
            }
            $CurrentWorryLevel = $CurrentWorryLevel % $LeastCommonMultiple
            if ($CurrentWorryLevel % $CurrentMonkey.TestValue -eq 0) {
                $Monkeys[$CurrentMonkey.TestPassMonkeyID].WorryLevels += $CurrentWorryLevel
            } else {
                $Monkeys[$CurrentMonkey.TestFailMonkeyID].WorryLevels += $CurrentWorryLevel
            }
            $CurrentMonkey.InSpectionCount++
        }
        $CurrentMonkey.WorryLevels = @()
    }
}

$InSpectionCountsSorted = ($Monkeys.InSpectionCount | Sort-Object -Descending)
$InSpectionCountsSorted[0] * $InSpectionCountsSorted[1]

# Correct answer = 20683044837 (2713310158 for testdata)