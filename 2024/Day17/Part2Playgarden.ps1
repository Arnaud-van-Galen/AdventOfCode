Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# $Program = (0,3,5,4,3,0)
$Program = (2,4,1,6,7,5,4,4,1,7,0,3,5,5,3,0)
$Guess = 0
while ($Result.Count -le $Program.Count) {
	$RegisterA, $RegisterB, $RegisterC, $InstructionPointer, $Result = $Guess, 0, 0, 0, @()
	while ($InstructionPointer -lt $Program.Length) {
		$OpCode = $Program[$InstructionPointer]
		$Operand = $Program[$InstructionPointer+1]
		$ComboOperands = (0, 1, 2, 3, $RegisterA, $RegisterB, $RegisterC, $null)
		if ($OpCode -in (0,2,5,6,7) -and $Operand -eq 7) { Write-Host "Operand should never get to 7 on operation 0" }
		switch ($OpCode) {
			0 {	$RegisterA = [System.Math]::Truncate($RegisterA / [System.Math]::Pow(2, $ComboOperands[$Operand])) }
			1 { $RegisterB = $RegisterB -bxor $Operand }
			2 { $RegisterB = $ComboOperands[$Operand] % 8 }
			3 { if ($RegisterA -ne 0) { $InstructionPointer = $Operand - 2 } } # Now we can just jump 2 always after the instruction
			4 { $RegisterB = $RegisterB -bxor $RegisterC }
			5 { $Result += $ComboOperands[$Operand] % 8	}
			6 {	$RegisterB = [System.Math]::Truncate($RegisterA / [System.Math]::Pow(2, $ComboOperands[$Operand])) }
			7 {	$RegisterC = [System.Math]::Truncate($RegisterA / [System.Math]::Pow(2, $ComboOperands[$Operand])) }
		}
		$InstructionPointer+=2
	}
	$Correct = $true
	for ($i = -1; $i -ge -1*$Result.Count; $i--) {
		if ($Result[$i] -ne $Program[$i]) {$Correct = $false; continue}
	}
	if ($Correct) {
		Write-Host "$Guess results in $($Result -join ',') with registers at ($RegisterA, $RegisterB, $RegisterC) and InstructionPointer at $InstructionPointer. Last Operand was $Operand"
		if ($Result.Count -eq $Program.Count) {break}
		$Guess = $Guess * 8 + 1
		# When just using $Guess*=8 it went correctly until 1461985568 to make 5,4,4,1,7,0,3,5,5,3,0 and then it would take too long to find the next value. Now it misses the testvalue by 1 though
		# I should check for when the $OpCode starts with a 0 to decide if the +1 is needed or not
	} else {
		# Write-Host "$Guess results in $($Result -join ',') with registers at ($RegisterA, $RegisterB, $RegisterC) and InstructionPointer at $InstructionPointer. Last Operand was $Operand" -ForegroundColor Red
		$Guess++
		# if ($Guess % 10000 -eq 0) {$Host.UI.RawUI.WindowTitle = "{0:N0}" -f $Guess}
	}
}
$Guess
# 47910079998866 for real data and 117440 (I miss this by 1) for the testdata