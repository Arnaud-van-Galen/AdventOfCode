Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

[string[]] $Result = @()
$InstructionPointer = 0
$RegisterA, $RegisterB, $RegisterC, $Program = [int[]][regex]::Matches($Data -join '', '(\d+)').Value

while ($InstructionPointer -lt $Program.Length) {
	$OpCode = $Program[$InstructionPointer]
	$Operand = $Program[$InstructionPointer+1]
	$ComboOperands = (0, 1, 2, 3, $RegisterA, $RegisterB, $RegisterC, $null)
	switch ($OpCode) {
		0 {	$RegisterA = [System.Math]::Truncate($RegisterA / [System.Math]::Pow(2, $ComboOperands[$Operand])) }
		1 { $RegisterB = $RegisterB -bxor $Operand }
		2 { $RegisterB = $ComboOperands[$Operand] % 8 }
		3 { if ($RegisterA -ne 0) { $InstructionPointer = $Operand - 2} } # Now we can just jump 2 always after the instruction
		4 { $RegisterB = $RegisterB -bxor $RegisterC }
		5 { $Result += $ComboOperands[$Operand] % 8 }
		6 {	$RegisterB = [System.Math]::Truncate($RegisterA / [System.Math]::Pow(2, $ComboOperands[$Operand])) }
		7 {	$RegisterC = [System.Math]::Truncate($RegisterA / [System.Math]::Pow(2, $ComboOperands[$Operand])) }
	}
	$InstructionPointer+=2
}

# Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host "Calculated answer: $($Result -join ',')"
Write-Host "Correct answer: 1,5,0,1,7,4,1,0,3 (4,6,3,5,6,3,5,2,1,0 for testdata)"
Write-Host "To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('C:','/mnt/c').Replace('\','/'))"
Write-Host "To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('/mnt/c','C:').Replace('/','\'))"