Get-Variable | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[System.Collections.Hashtable] $SevenDigitDisplay = @{
  0 = "abcefg"
  1 = "cf"
  2 = "acdeg"
  3 = "acdfg"
  4 = "bcdf"
  5 = "abdfg"
  6 = "abdefg"
  7 = "acf"
  8 = "abcdefg"
  9 = "abcdfg"
}

[string[]] $DataInput = "acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf"
# [string[]] $DataInput = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
# [string[]] $DataInput = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

foreach ($Entry in $DataInput) {
  # In part one we looked at the occurences of numbers and discovered that 1, 4, 7 (and 8) are easily discovered.
  # By looking at the occurences of segments and combining them with the 1,4,7 knowledge we can easily built up a WireChanges Dictionary which is basically a decryption key 
  # b occurs 6 times, e 4 times, f 9 times, a_and_c 8 times, d_and_g 7 times ( Evidence: $SevenDigitDisplay.Values.ToCharArray() | Group-Object -NoElement | Sort-Object -Property Count )
  # This one observation removes complexity from 7! = 720 to 2! * 2! = 4
  # a_and_c can be discovered because a is in 7 but not in 1 which leaves only 1 option for c
  # d_and_g can be discovered because d is in 4 while g is not which leaves only 1 option for g
  [string[]] $SignalPatterns = $Entry.Split("|")[0].Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)
  [System.Collections.Hashtable] $WireChanges = @{}
  $One = $SignalPatterns | Where-Object -Property Length -eq $SevenDigitDisplay[1].Length
  $Four = $SignalPatterns | Where-Object -Property Length -eq $SevenDigitDisplay[4].Length
  $Seven = $SignalPatterns | Where-Object -Property Length -eq $SevenDigitDisplay[7].Length
  $SegmentCount = $SignalPatterns.ToCharArray() | Group-Object -NoElement
  $WireChanges.Add("b", ($SegmentCount | Where-Object -Property Count -eq 6).Name)
  $WireChanges.Add("e", ($SegmentCount | Where-Object -Property Count -eq 4).Name)
  $WireChanges.Add("f", ($SegmentCount | Where-Object -Property Count -eq 9).Name)
  $WireChanges.Add("a", (Compare-Object $One.ToCharArray() $Seven.ToCharArray() -PassThru))
  $WireChanges.Add("c", ($SegmentCount | Where-Object -Property Count -eq 8 | Where-Object -Property Name -ne $WireChanges["a"]).Name)
  $WireChanges.Add("d", $Four.ToCharArray().Where( { $_ -notin $WireChanges.Values } )[0])
  $WireChanges.Add("g", "abcdefg".ToCharArray().Where( { $_ -notin $WireChanges.Values } )[0])

  [string[]] $OutputValues = $Entry.Split("|")[1].Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)
  foreach ($OutputValue in $OutputValues) {
    #[string] $CorrectedOutputValue = ""
    #$OutputValue.ToCharArray() | Sort-Object
    #cdbaf should become acdfg
    #Write-Host $WireChanges[($OutputValue.ToCharArray() | Sort-Object).ForEach({$_.ToString()})]
  }
}
# Correct answer = ? (5353 en 61229 for testdata)
