Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

class MyClass {
    $MyClassProperty = "Het werkt!"
}
$x = [MyClass]::new()
$x.Count
$x.GetType()
$x.MyClassProperty

$y = [MyClass[]]::new(2)
$y.Count
$y.GetType()
$y[0] = [MyClass]::new()
$y[0].MyClassProperty

$a = "abcde"
$b = $a.ToCharArray()
[array]::Reverse($b) # $b is now the reversed characterarray ("e", "d", "c", "b", "a") and can be changed back to "edcba" with -join $b

$array = @(1,2,3)
$array_ref = $array
$array_val = $array.ForEach{ $_ } # https://www.powershelladmin.com/wiki/Deep_copying_arrays_and_objects_in_PowerShell.php
$array[0] = 11
$array_ref[1] = 12
$array_val[2] = 13
Write-Output $array, $array_ref, $array_val -NoEnumerate

$strings=@"
123
456
"@.split()
$intarray = [int32[]]::new($strings.count)
# Doesn't work yet. Work in Progress / ToDo. Should become (1,2,3),(4,5,6)
$strings.foreach{$_.ToCharArray().foreach{$intarray[$foreach]=[int]$_.tostring()}}

$data = "[1,[2,[3,[4,[5,6,7]]]],8,9]"
$datePattern = [Regex]::new("\[*\]")
$matches = $datePattern.Matches($data)
$matches.Value