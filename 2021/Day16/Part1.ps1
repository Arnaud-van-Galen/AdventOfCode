Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

$ToDo = [System.Collections.Stack]::new() # https://docs.microsoft.com/en-us/dotnet/api/system.collections.stack.pop?view=net-6.0
class Action {
    [int] $BeginPosition
    [int] $EndPosition
    [string] $Type
    [Int64] $Value
    Action( [int] $BeginPosition, [int] $EndPosition, [string] $Type, [int64] $Value ) {
        $this.BeginPosition = $BeginPosition
        $this.EndPosition = $EndPosition
        $this.Type = $Type
        $this.Value = $Value
    }
}
class Step {
    [string] $Action = "Version"
    [int] $Take = 3
    [System.Collections.ArrayList] $ToDoLengthRemaining = @{}
}
$Actions = [System.Collections.ArrayList]::new()
$Step = [Step]::new()
$CurrentPosition = 0

# $HexString = "D2FE28" # VersionSum = 6 (Ve=6 Ty=4 Li=2021)
# $HexString = "38006F45291200" # VersionSum = 9 (Ve=1 Ty=6 Id=0 Le=27 Ve=6 Ty=4 Li=10 Ve=2 Ty=4 Li=20)
# $HexString = "EE00D40C823060"# VersionSum = 14 (Ve=7 Ty=3 Id=1 Nu=3 Ve=2 Ty=4 Li=1 Ve=4 Ty=4 Li=2 Ve=1 Ty=4 Li=3)
# $HexString = "8A004A801A8002F478" # VersionSum = 16 (Ve=4 Ty=2 Id=1 Nu=1 Ve=1 Ty=2 Id=1 Nu=1 Ve=5 Ty=2 Id=0 Le=11 Ve=6 Ty=4 Li=15)
# $HexString = "620080001611562C8802118E34" # VersionSum = 12 (Ve=3 Ty=0 Id=1 Nu=2 Ve=0 Ty=0 Id=0 Le=22 Ve=0 Ty=4 Li=10 Ve=5 Ty=4 Li=11 Ve=1 Ty=0 Id=1 Nu=2 Ve=0 Ty=4 Li=12 Ve=3 Ty=4 Li=13)
# $HexString = "C0015000016115A2E0802F182340" # VersionSum = 23 (Ve=6 Ty=0 Id=0 Le=84 Ve=0 Ty=0 Id=0 Le=22 Ve=0 Ty=4 Li=10 Ve=6 Ty=4 Li=11 Ve=4 Ty=0 Id=1 Nu=2 Ve=7 Ty=4 Li=12 Ve=0 Ty=4 Li=13)
# $HexString = "A0016C880162017C3686B18A3D4780" # VersionSum = 31 (Ve=5 Ty=0 Id=0 Le=91 Ve=1 Ty=0 Id=1 Nu=1 Ve=3 Ty=0 Id=1 Nu=5 Ve=7 Ty=4 Li=6 Ve=6 Ty=4 Li=6 Ve=5 Ty=4 Li=12 Ve=2 Ty=4 Li=15 Ve=2 Ty=4 Li=15)
$HexString = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop


$ByteString = $HexString.ToCharArray().ForEach{[convert]::ToString("0x"+$_,2).PadLeft(4, "0")} | Join-String

$ToDo.Push($Step)
# Version - Type(=4) - LiteralValue
# Version - Type(<>4) - Id(0) - Length15 - (Version - Type)TotalLike27Bits
# Version - Type(<>4) - Id(1) - Number11 - (Version - Type)TotalLike3Packets
While ($CurrentPosition -le $ByteString.Length -and $ToDo.Count -gt 0 -and $ByteString.Substring($CurrentPosition).Contains("1")) {
    $Step = $ToDo.Peek() 
    [void] $ToDo.Pop()
    switch ($Step.Action) {
        "Version" {
            $NextPosition = $CurrentPosition + $Step.Take
            $Version = [Convert]::ToInt32($ByteString.Substring($CurrentPosition, $Step.Take), 2)
            [void] $Actions.Add( [Action]::new($CurrentPosition, $NextPosition, "Version", $Version ) )
            $NextStep = [Step]::new()
            $NextStep.Action = "Type"
            $NextStep.Take = 3
            $NextStep.ToDoLengthRemaining = $Step.ToDoLengthRemaining.ForEach{$_ - $Step.Take}
            $ToDo.Push($NextStep)
            $CurrentPosition = $NextPosition
        }
        "Type" {
            $NextPosition = $CurrentPosition + $Step.Take
            $Type = [Convert]::ToInt32($ByteString.Substring($CurrentPosition, $Step.Take), 2)
            [void] $Actions.Add( [Action]::new($CurrentPosition, $NextPosition, "Type", $Type ) )
            $NextStep = [Step]::new()
            if ($Type -eq 4) {
                $NextStep.Action = "LiteralValue"
                $NextStep.Take = 5
            } else { 
                $NextStep.Action = "Id"
                $NextStep.Take = 1
            }
            $NextStep.ToDoLengthRemaining = $Step.ToDoLengthRemaining.ForEach{$_ - $Step.Take}
            $ToDo.Push($NextStep)
            $CurrentPosition = $NextPosition
        }
        "LiteralValue" {
            $NextPosition = $CurrentPosition + $Step.Take
            $PartCount = $Step.Take / 5
            $LastLiteralValuePart = $ByteString.Substring($CurrentPosition + ($PartCount - 1) * 5, 5) #Last 5 only
            $NextStep = [Step]::new()
            if ($LastLiteralValuePart[0].ToString() -eq 1) {
                $NextStep.Action = "LiteralValue"
                $NextStep.Take = $Step.Take + 5
                $ToDo.Push($NextStep)
            } else {
                $LiteralValueString = $ByteString.Substring($CurrentPosition, $Step.Take)
                for ($i = $PartCount - 1; $i -ge 0; $i--) {
                    $LiteralValueString = $LiteralValueString.Remove($i * 5, 1)
                }
                $LiteralValue = [Convert]::ToInt64($LiteralValueString, 2)
                [void] $Actions.Add( [Action]::new($CurrentPosition, $NextPosition, "LiteralValue", $LiteralValue ) )
                if ($Step.ToDoLengthRemaining.Count -gt 0) {
                    $Step.ToDoLengthRemaining = $Step.ToDoLengthRemaining.ForEach{$_ - $Step.Take}
                    $NextStep.ToDoLengthRemaining = $Step.ToDoLengthRemaining.Where{$_ -gt 0}
                    if ($NextStep.ToDoLengthRemaining.Count -gt 0) {
                        $NextStep.Action = "Version"
                        $NextStep.Take = 3
                        $ToDo.Push($NextStep)
                    }
                }
                $CurrentPosition = $NextPosition
                if ($ToDo.Count -eq 0 -and $ByteString.Length -gt $CurrentPosition -and $ByteString.Substring($CurrentPosition).Contains("1")) {
                    $ToDo.Push([Step]::new())
                }
            }
        }
        "Id" {
            $NextPosition = $CurrentPosition + $Step.Take
            $Id = [Convert]::ToInt32($ByteString.Substring($CurrentPosition, $Step.Take), 2)
            [void] $Actions.Add( [Action]::new($CurrentPosition, $NextPosition, "Id", $Id ) )
            $NextStep = [Step]::new()
            if ($Id -eq 0) { 
                $NextStep.Action = "Length"
                $NextStep.Take = 15
            } else { 
                $NextStep.Action = "Number"
                $NextStep.Take = 11
            }
            $NextStep.ToDoLengthRemaining = $Step.ToDoLengthRemaining.ForEach{$_ - $Step.Take}
            $ToDo.Push($NextStep) 
            $CurrentPosition = $NextPosition
        }
        "Length" {
            $NextPosition = $CurrentPosition + $Step.Take
            $Length = [Convert]::ToInt32($ByteString.Substring($CurrentPosition, $Step.Take), 2)
            [void] $Actions.Add( [Action]::new($CurrentPosition, $NextPosition, "Length", $Length ) )
            $NextStep = [Step]::new()
            $NextStep.Action = "Version"
            $NextStep.Take = 3
            $NextStep.ToDoLengthRemaining = $Step.ToDoLengthRemaining.ForEach{$_ - $Step.Take}
            $NextStep.ToDoLengthRemaining += $Length
            $ToDo.Push($NextStep)
            $CurrentPosition = $NextPosition
        }        
        "Number" {
            $NextPosition = $CurrentPosition + $Step.Take
            $Number = [Convert]::ToInt32($ByteString.Substring($CurrentPosition, $Step.Take), 2)
            [void] $Actions.Add( [Action]::new($CurrentPosition, $NextPosition, "Number", $Number ) )
            for ($i = 0; $i -lt $Number; $i++) {
                $NextStep = [Step]::new()
                $NextStep.Action = "Version"
                $NextStep.Take = 3
                $NextStep.ToDoLengthRemaining = $Step.ToDoLengthRemaining.ForEach{$_ - $Step.Take}
                $ToDo.Push($NextStep)
            }
            $CurrentPosition = $NextPosition
        }
    }
}
$Actions.where{$_.Type -eq "version"} | Measure-Object  -Property Value -Sum | Select-Object -ExpandProperty Sum
# Correct answer = 936 (see HexStrings-section for testdata and details in the Examples.txt)
# $Actions.ForEach{$_.Type.Substring(0,2), "=", $_.Value, " "} | Join-String