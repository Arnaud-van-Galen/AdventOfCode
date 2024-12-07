Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[Int64] $Result = 0
$Operators = @('*','+')

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

foreach ($DataLine in $Data) {
	$DesiredResult = [Int64] $DataLine.Split(': ')[0]
	$Factors = [Int64[]] $DataLine.Split(': ')[1].Split(' ')
	$Stack = [System.Collections.Stack]::new()
	$Stack.Push(@($DesiredResult, ($Factors.Count-1), ($Operators.Count-1)))
	while ($Stack.Count -gt 0) {
		$LeftOverResult, $FactorIndex, $OperatorIndex = $Stack.Pop()
		$Factor = $Factors[$FactorIndex]
		$Operator = $Operators[$OperatorIndex]
		switch ($Operator) {
			'*' { $OperationResult = $LeftOverResult / $Factor; $OperationValid = [int64]$OperationResult -eq $OperationResult; break }
			'+' { $OperationResult = $LeftOverResult - $Factor; $OperationValid = $OperationResult -ge 0; break }
		}
		$NextFactorExists = $FactorIndex -gt 0
		$NextOperatorExists = $OperatorIndex -gt 0
		$ReachedZeroAtTheEnd = $OperationResult -eq 0 -and !$NextFactorExists
		if ($ReachedZeroAtTheEnd) {
			$Result += $DesiredResult
			break # stop the current stack/while and continue with the next dataline
		}
		if ($NextFactorExists -or $NextOperatorExists) {
			if ($OperationValid -and $NextFactorExists) {
				$Stack.Push(@($OperationResult, ($FactorIndex-1), ($Operators.Count-1))) # Met volgende factor alle operators doorlopen op de waarde van na de operatie
			}
			if ($NextOperatorExists) {
				$Stack.Push(@($LeftOverResult, $FactorIndex, ($OperatorIndex-1))) # Met huidige factor de volgende operator doorlopen op de waarde van voor de test
			}
		}
	}
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 7885693428401 (3749 for testdata)