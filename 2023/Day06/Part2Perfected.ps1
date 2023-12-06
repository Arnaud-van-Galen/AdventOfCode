Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
[Int64]$Time = $Data[0].split(':')[1].Replace(' ','')
[Int64]$Distance = $Data[1].split(':')[1].Replace(' ','')
# "abc"-formula with a=1, b=-Time, c=Distance. Test with Time=30, Distance=200 to see an edge case
#   t*(30-t) > 200
#   -t*t + 30*t - 200 > 0
#   1*t^2 - 30*t + 200 < 0
#   Multiplying by -1 makes the next part easier to understand because
#       a disappears,
#       --b becomes b and -b*-b=b*b
#       c becomes positive as well
#       D becomes easy to understand why t1 is the lower one and t2 is the highter one
#       t1 might need to be and might need adjusting upwards  
#   Solved for t = 0 but adjustment for t1 (upwards) and t2 (downwards) may be needed because it should be t < 0 to win
$D=[Math]::Sqrt($Time*$Time-4*$Distance)
$t1=($Time-$D)/2
$t2=($Time+$D)/2
$t1adjusted = [Math]::Ceiling($t1) -eq $t1 ? $t1+1 : [Math]::Ceiling($t1)
$t2adjusted = [Math]::Floor($t2) -eq $t2 ? $t2-1 : [Math]::Floor($t2)
$Result = $t2adjusted - $t1adjusted + 1

Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Write-Host "$Result (from holding $t1adjusted to $t2adjusted milliseconds you will beat distance $Distance in $Time milliseconds total)"
# Correct answer = 33149631 (71503 for testdata)