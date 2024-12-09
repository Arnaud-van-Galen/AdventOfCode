<#
Just a work in progress with lots of performance tests
It doesn't direct address the puzzle of the day yet
It does try to create a prepopulated array with all operators. Something like this (for 3^2. Should be 3^11)
  00, 01, 02, 10, 11, 12, 21, 22, 23
#>
Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()
# $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds

# Settings
$OperatorCount = 3
$FactorCount = 9
$MaxValue = [System.Math]::Pow($OperatorCount, $FactorCount)
$RunTests = @($True)

function Convert-NumberToBase { param ([int]$Number, [int]$Base)
	$Result = ""
	do {
		$Remainder = $Number % $Base
		$Result = "$Remainder$Result"
		$Number = [math]::Floor($Number / $Base)
	} while ($Number -gt 0)
	return $Result
}

# DivRem the function
function Convert-NumberToBaseDivRem { param ([int]$Number, [int]$Base)
	$Result = ""
	do {
		$Remainder = $Number % $Base
		$Result = "$Remainder$Result"
		$Number = [math]::Floor($Number / $Base)

		[int] $quotient=0, [int] $remainder
		[math]::DivRem($current, 3, [ref]$quotient)
		
		$Result = "$remainder$Result"
		$current = $quotient

	} while ($Number -gt 0)
	return $Result
}

# Just call the function: 1.02 seconds for 3,9
# (Measure-Command {
# 	for ($i = $0; $i -lt $MaxValue; $i++) {
# 		Convert-NumberToBase -Number $i -Base $OperatorCount
# 	}
# }).TotalSeconds


# DivRema and memoize the function
<#
# Implement memoization to cache results for performance improvement
$memoBase3 = @{}

function Convert-ToBase3 {
    param (
        [int]$number
    )

    # Check the cache first 
    if ($memoBase3.ContainsKey($number)) {
        return $memoBase3[$number]
    }

    $base3 = ""
    $current = $number

    do {
        # Using [math]::DivRem for optimization of division and remainder
        [int] $quotient, [int] $remainder
        [math]::DivRem($current, 3, [ref]$quotient)
        
        $base3 = "$remainder$base3"
        $current = $quotient
    } while ($current -gt 0)

    # Store the result in memoization cache
    $memoBase3[$number] = $base3
    return $base3
}

# Example for a smaller range to verify performance improvements
$startValue = 0
$endValue = 242 # Example range for demonstrating functionality

# Creating an array of base 3 values
$base3Values = @()

for ($i = $startValue; $i -le $endValue; $i++) {
    $base3Values += Convert-ToBase3 -number $i
}

# Output the array
$base3Values
#>

# Inline the function: 0,02 for 3.9. 3.99 for 3,10. 11,73 for 3.11
(Measure-Command {
	for ($i = $0; $i -lt $MaxValue; $i++) {
		$Number = $i
		$Base = $OperatorCount
		$Result = ""
		do {
			$Remainder = $Number % $Base
			$Result = "$Remainder$Result"
			$Number = [math]::Floor($Number / $Base)
		} while ($Number -gt 0)
	}
	Write-Host "Verification: $Result"
}).TotalSeconds

# # Creating an array of base 3 values
# $base3Values = @()
# for ($i = $startValue; $i -le $MaxValue; $i++) {
# 	$base3Values += Convert-ToBase3 -number $i
# }