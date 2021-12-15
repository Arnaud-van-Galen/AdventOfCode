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