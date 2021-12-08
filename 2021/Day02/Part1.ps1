Get-Variable | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[int] $Horizontal = 0
[int] $Vertical = 0

# [string[]] $Course = "forward 5","down 5","forward 8","up 3","down 8","forward 2"
[string[]] $Course = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

foreach($Movement in $Course) {
    [String] $Direction, [int] $Amount = $Movement.Split(" ")
    # Write-Host "Direction: $Direction, Amount: $Amount"
    switch ($Direction) {
        "forward" { $Horizontal += $Amount ; break }
        "down" { $Vertical += $Amount ; break }
        "up" { $Vertical -= $Amount ; break }
    }
    # Write-Host "Horizontal: $Horizontal, Vertical: $Vertical"
}

Write-Host "Total movement after multiplication: $($Horizontal * $Vertical)"
# Correct answer = 1728414 (150 for testdata)
