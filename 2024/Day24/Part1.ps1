Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
Set-StrictMode -Version Latest
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# $Data = Get-Content -Path $PSScriptRoot\DataDemo1.txt -ErrorAction Stop
# $Data = Get-Content -Path $PSScriptRoot\DataDemo2.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

$Inputs = @{}
$Gates = @{}
[regex]::Matches($Data -join '','(?<Input1>.{3}) (?<Operator>XOR|OR|AND) (?<Input2>.{3}) -> (?<Output>.{3})').ForEach{
$Gates[$_.Groups['Output'].Value] = ($_.Groups['Input1','Input2','Operator'].Value)
$Inputs[$_.Groups['Output'].Value] = $null
}
[regex]::Matches($Data -join '','(.{3}): (\d)').ForEach{$Inputs[$_.groups[1].Value] = [int]$_.Groups[2].Value}
$LoopCounter = 0
do {
	foreach ($Gate in $Gates.GetEnumerator()) {
		$Input1, $Input2, $Operator = $Gate.Value
		if ($null -ne $Inputs[$Input1] -and $null -ne $Inputs[$Input2]) {
			switch ($Operator) {
				XOR { $Inputs[$Gate.Key] = $Inputs[$Input1] -xor $Inputs[$Input2] }
				OR { $Inputs[$Gate.Key] = $Inputs[$Input1] -or $Inputs[$Input2] }
				AND { $Inputs[$Gate.Key] = $Inputs[$Input1] -and $Inputs[$Input2] }
				Default { Write-Host "Invalid operator" -ForegroundColor Red }
			}
		}
	}
	$ZInputs = $Inputs.GetEnumerator().Where{$_.Key.StartsWith('z')} | Sort-Object -Descending
	$LoopCounter++
	# Write-Host "Times we went through the loop: $LoopCounter. There are still $($ZInputs.Where{$null -eq $_.Value}.Count) empty z-values out of $($ZInputs.Count) z-values and $($Inputs.Count) total inputs"
} while ($ZInputs.Where{$null -eq $_.value})

# Get-MyVariables
Write-Host 'Time for calculating:', $stopwatch.Elapsed.TotalSeconds
Write-Host 'Calculated answer:', ([convert]::ToInt64(([int[]]$Zinputs.Value -join ''), 2))
Write-Host 'Correct answer: 54715147844840 (4 for testdata1, 2024 for testdata2)'
Write-Host 'To run this command on Ubuntu WSL: wsl pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('C:','/mnt/c').Replace('\','/')
Write-Host 'To run this command on Windows:        pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -File', $PSCommandPath.Replace('/mnt/c','C:').Replace('/','\')