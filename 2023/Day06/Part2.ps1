Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

[Int64] $Result = 1

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
[Int64]$Time = $Data[0].split(':')[1].Replace(' ','')
[Int64]$Distance = $Data[1].split(':')[1].Replace(' ','')
# t*(71530-t) > 940200
# -t*t + 71530t - 940200 > 0
$a, $b, $c = -1, $Time, -$Distance
$D=[Math]::Sqrt($b*$b-4*$a*$c)
$t1=(-$b+$D)/(2*$a)
$t2=(-$b-$D)/(2*$a)
$Result = [Math]::Floor($t2) - [Math]::Ceiling($t1) + 1

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host $Result
# Correct answer = 33149631 (71503 for testdata)