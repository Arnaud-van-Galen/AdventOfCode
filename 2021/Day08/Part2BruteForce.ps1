Get-Variable | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[System.Collections.Hashtable] $SevenDigitDisplay = @{
  "abcefg" = 0
  "cf" = 1
  "acdeg" = 2
  "acdfg" = 3
  "bcdf" = 4
  "abdfg" = 5
  "abdefg" = 6
  "acf" = 7
  "abcdefg" = 8
  "abcdfg" = 9
}
[System.Collections.Hashtable] $SevenDigitDisplayReverted = @{}
$SevenDigitDisplay.Keys.ForEach( { $SevenDigitDisplayReverted.Add($SevenDigitDisplay[$_].ToString(), $_.ToString()) } )

[string[]] $DataInput = "acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf"
# [string[]] $DataInput = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
# [string[]] $DataInput = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop
[string[]] $DecryptionKey = "adcbgef", "dfaecgb", "zyxwvut"
# [string[]] $DecryptionKeys = Get-Content -Path $PSScriptRoot\DecryptionKeys.txt -ErrorAction Stop

[int] $DisplayValueSum = 0
foreach ($Entry in $DataInput) {
  [string[]] $SignalPatterns = $Entry.Split("|")[0].Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)
  [bool] $ValidDecryptionKey = $true
  foreach ($SignalPattern in $SignalPatterns) {
    $WireChanges = @{}
    $Keys = "adcbgef".ToCharArray()
    $Segments = "abcdefg".ToCharArray()
    for ($i = 0; $i -lt 7; $i++) { $WireChanges.Add( $Segments[$i], $Keys[$i] ) }
    $WireChanges[ ($OutputValue.ToCharArray()).ForEach( { $_.ToString() } ) ] | Sort-Object | Join-String
    $WireChangesReverted = ${}

# ToDo, continue from here
    $WireChanges.Keys.ForEach( { $WireChangesReverted.Add($WireChanges[$_].ToString(), $_.ToString()) } )

  

  [System.Collectios.Hashtable] $WireChanges = @{}
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
  $WireChanges.Add("g", ($SegmentCount | Where-Object -Property Count -eq 7 | Where-Object -Property Name -ne $WireChanges["d"]).Name)
  [System.Collections.Hashtable] $WireChangesReverted = @{}
  $WireChanges.Keys.ForEach( { $WireChangesReverted.Add($WireChanges[$_].ToString(), $_.ToString()) } )

  [string[]] $OutputValues = $Entry.Split("|")[1].Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)
  [string] $RevertedOutputValue = ""
  foreach ($OutputValue in $OutputValues) {
    [string] $CorrectedOutputValue = $WireChangesReverted[ ($OutputValue.ToCharArray()).ForEach( { $_.ToString() } ) ] | Sort-Object | Join-String
    $RevertedOutputValue += $SevenDigitDisplayReverted[$CorrectedOutputValue]
  }
  $DisplayValueSum += [int] $RevertedOutputValue
}

Write-Host $DisplayValueSum
# Correct answer = 1011785 (5353 en 61229 for testdata)