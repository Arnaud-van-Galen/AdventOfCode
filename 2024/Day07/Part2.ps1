Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[Int64] $Result = 0
# $Operators = @('*','&','+') # *&+ 160, *+& 146, +*& 141, +&* 136, &+* 133, &*+ 138 Windows
$Operators = @('*','&','+') # *&+ 44, *+& 45, +*& 44, +&* 45, &+* 48, &*+ 44 WSL/Ubuntu

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

foreach ($DataLine in $Data) {
	# "$(Get-Date), $DataLine"
	$DesiredResult = [Int64] $DataLine.Split(': ')[0]
	$Factors = [Int64[]] $DataLine.Split(': ')[1].Split(' ')
	$Stack = [System.Collections.Stack]::new()
	$Stack.Push(@($Factors[0], 1, 0))
	while ($Stack.Count -gt 0) {
		$FactorLeft, $FactorIndex, $OperatorIndex = $Stack.Pop()
		$Operator = $Operators[$OperatorIndex]
		switch ($Operator) {
			'*' { $OperationResult = $FactorLeft * $Factors[$FactorIndex] ; break }
			'&' { $OperationResult = [long]"$($FactorLeft)$($Factors[$FactorIndex])" ; break }
			'+' { $OperationResult = $FactorLeft + $Factors[$FactorIndex] ; break}
		}
		$OperationValid = $OperationResult -le $DesiredResult
		$NextFactorExists = $Factors.Count-1 -gt $FactorIndex
		$NextOperatorExists = $Operators.Count-1 -gt $OperatorIndex
		$ReachedMatchingAtTheEnd = $OperationResult -eq $DesiredResult -and !$NextFactorExists
		if ($ReachedMatchingAtTheEnd) {
			$Result += $DesiredResult
			break # stop the current stack/while and continue with the next dataline
		}
		if ($NextFactorExists -or $NextOperatorExists) {
			if ($OperationValid -and $NextFactorExists) {
				$Stack.Push(@($OperationResult, ($FactorIndex+1), 0)) # Met volgende factor alle operators doorlopen op de waarde van na de operatie
			}
			if ($NextOperatorExists) {
				$Stack.Push(@($FactorLeft, $FactorIndex, ($OperatorIndex+1))) # Met huidige factor de volgende operator doorlopen op de waarde van voor de test
			}
		}
	}
}

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 348360680516005 (11387 for testdata)