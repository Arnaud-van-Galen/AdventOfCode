Get-MyVariables | Remove-Variable -ErrorAction SilentlyContinue
[System.Console]::Clear()

[string] $Path = "/" # Make sure to always end Path with a /
[hashtable] $Files = @{}
[hashtable] $Folders = @{}
[int] $TotalSizeLimit = 100000
[int] $TotalSize = 0

# $Data = Get-Content -Path $PSScriptRoot\DataDemo.txt -ErrorAction Stop
$Data = Get-Content -Path $PSScriptRoot\Data.txt -ErrorAction Stop

foreach ($TerminalLine in $Data) {
    if ($TerminalLine.StartsWith("$")) {
        if ($TerminalLine.StartsWith("$ cd")) {
            $PathChange = $TerminalLine.Split(" ")[2]
            switch ($PathChange) {
                "/" {
                    $Path = "/"
                    break
                }
                ".." {
                    if ($Path -ne "/") {
                        $SecondToLastSlash = $Path.Substring(0, $Path.Length - 1).LastIndexOf("/")
                        $Path = $Path.Substring(0, $SecondToLastSlash) + "/"
                    }
                }
                Default {
                    $Path += $PathChange + "/"
                }
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

foreach ($Folder in $Folders.Values) {
    if ($Folder -le $TotalSizeLimit) {
        $TotalSize += $Folder
    }
}

Write-Host "Total size of at most $TotalSizeLimit is $TotalSize"
# Correct answer = 1477771 (95437 for testdata)