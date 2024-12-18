# Hurrying to the next challenge. Correct solution is in Part2PlayGarden.ps1.
# ToDo: Mix the nice structure and variable getting here with the correct program in PlayGarden

Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# $Data = Get-Content -Path $PSScriptRoot\DataDemo2.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

[string[]] $Result = @()
$InstructionPointer = 0
$RegisterA, $RegisterB, $RegisterC, $Program = [int[]][regex]::Matches($Data -join '', '(\d+)').Value

# for ($i = 0; $i -lt $Program.Count; $i++) {
# 	$Octal = $Program[$Program.Count-1-$i]
# 	$Factor = [System.Math]::Pow(8, $i)
# 	Write-Host "i = $i, Octal = $Octal, Factor = $Factor. $($Octal*$Factor)"
# } # 

$RegisterA = 117440 # for Program: 0,3,5,4,3,0. 117440/8 => 14680,0. 14680/8 => 1835,0. 1835/8 => 229,3. 229 => 28,5 => 3,4 => 3,0
# $RegisterA = 117441 # for Program: 0,3,5,4,3,0. 117440/8 => 14680,0. 14680/8 => 1835,0. 1835/8 => 229,3. 229 => 28,5 => 3,4 => 3,0
$Program = (2,4,1,6,7,5,4,4,1,7,0,3,5,5,3,0)
[Int64[]]$Guesses = (
	2416754417035530, # 3,2,4,0,1,2,1,4,2,1,0,2,4,6,0,4,1,0	Too high. Length 18 instead of 16
	555555555555555,	# 5,2,5,2,7,6,5,2,0,4,2,7,0,4,1,1,0 	Too high. Length 17 instead of 16
	55555555555555,		# 5,2,5,2,5,1,4,0,6,1,2,0,5,0,6,0			Too high, but length 16 starting with 5 instead of 2
	44444444444444,		# 2,5,2,1,6,0,0,0,5,7,7,1,1,0,3,0			Too high, but starting with 2
	16313251724384,
	130506013795088
)
foreach ($i in $Guesses) {
	$RegisterA, $RegisterB, $RegisterC, $InstructionPointer,$Result = $i,0,0,0,@()
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
	$Result -join ','
}
$Program.Length, $Result.Length

# Get-MyVariables
Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host "Calculated answer: $($Result -join ',')"
Write-Host "Correct answer: 47910079998866 (117440 for testdata)"
Write-Host "To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('C:','/mnt/c').Replace('\','/'))"
Write-Host "To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File $($PSCommandPath.Replace('/mnt/c','C:').Replace('/','\'))"