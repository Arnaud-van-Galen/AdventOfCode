[int]$Horizontal=0
[int]$Vertical=0

#[string[]]$Course="forward 5","down 5","forward 8","up 3","down 8","forward 2"
[string[]]$Course=Get-Content .\02-1-Input.txt

foreach($Movement in $Course) {
    [String]$Direction=$Movement.Split(" ")[0]
    [int]$Amount=$Movement.Split(" ")[1]
    #Write-Host "Direction: $Direction, Amount: $Amount"
    switch ($Direction) {
        "forward" {$Horizontal+=$Amount;break}
        "down" {$Vertical+=$Amount;break}
        "up" {$Vertical-=$Amount;break}
    }
    #Write-Host "Horizontal: $Horizontal, Vertical: $Vertical"
}
Write-Host "Total movement after multiplication: $($Horizontal*$Vertical)"
