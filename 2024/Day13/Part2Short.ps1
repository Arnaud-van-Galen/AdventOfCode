$Numbers = [regex]::Matches((Get-Content -Path $PSScriptRoot\Data.txt -Raw), '\d+') # Get all Numbers from inputfile
for ($i = 0; $i -lt $Numbers.Count; $i+=6) { # Numbers are grouped per 6...
	$ax,$ay,$bx,$by,$px,$py = [Int64[]]($Numbers[$i..($i+6-1)].Value) # ...so assign them per 6 with the correct type
	$b = (($px+10000000000000)*$ay-($py+10000000000000)*$ax) / ($bx*$ay-$by*$ax) # 2 Equations with 2 variables. Remove $a by multiplying $ax with $ay...
	$a = ($px+10000000000000-$bx*$b)/$ax # ...and then find $a by substituting $b back in
	if ($a -eq [Int64]$a -and $b -eq [Int64]$b) {$Wins++ ; $Result+=$a*3+$b} # calculate the needed coins only when $a and $b are whole numbers
	"Entry $($i/6), Input $ax,$ay,$bx,$by,$px,$py, B presses $b, A presses $a. For $($Wins ?? 0) Wins the amount of Coins needed is $($Result ?? 0)"
}