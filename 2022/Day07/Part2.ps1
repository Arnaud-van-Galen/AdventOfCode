Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[string] $Path = "/" # Make sure to always end Path with a /
[hashtable] $Files = @{}
[hashtable] $Folders = @{}
[int] $DiskSpaceTotal = 70000000
[int] $DiskSpaceNeeded = 30000000

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

foreach ($TerminalLine in $Data) {
    if ($TerminalLine.StartsWith("$")) {
        if ($TerminalLine.StartsWith("$ cd")) {
            $PathChange = $TerminalLine.Split(" ")[2]
            if ($PathChange -eq "/") {
                $Path = "/"
            } elseif ($PathChange -eq "..") {
                if ($Path -ne "/") {
                    $SecondToLastSlash = $Path.Substring(0, $Path.Length - 1).LastIndexOf("/")
                    $Path = $Path.Substring(0, $SecondToLastSlash) + "/"
                }
            } else {
                $Path += $PathChange + "/"
            }
        }
    }
    else {
        $lsPart1, $lsPart2 = $TerminalLine.Split(" ")
        if ($lsPart1 -ne "dir") {
            $Files.Add($Path + $lsPart2, [int]$lsPart1)
        }
    }
}

foreach ($File in $Files.Keys) {
    $FileParts = $File.Split("/")
    for ($i = 0; $i -lt $FileParts.Count - 1; $i++) {
        $currentFolder = ($FileParts[0..$i] -join "/") + "/"
        $Folders[$currentFolder] += $Files[$File]
    }
}

$UsedSpace = $Folders["/"]
$UsedSpaceNeeded = $DiskSpaceNeeded - ($DiskSpaceTotal - $UsedSpace)
foreach ($FolderSize in $Folders.Values | Sort-Object) {
    if ($FolderSize -ge $UsedSpaceNeeded) {
        $FolderSize
        break
    }
}

# Correct answer = 3579501 (24933642 for testdata)