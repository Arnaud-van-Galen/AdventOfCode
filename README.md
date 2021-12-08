https://deltanoffice365.sharepoint.com/sites/dev/SitePages/Advent-of-Code-2021.aspx
https://teams.microsoft.com/_#/conversations/19:82824b8c67ac4964870839c6f6cb22dc@thread.v2?ctx=chat
https://adventofcode.com/2021/leaderboard/private/view/676063

Useful for measuring performance:
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds
Useful for making sure that variables and output are reset:
     Get-Variable | Remove-Variable -ErrorAction SilentlyContinue
     [System.Console]::Clear()

Most code follows these principle:
    Files:
        yyyy\Daydd\Data[Demo].txt
        yyyy\Daydd\Partn.ps1
        Sometimes there is an extra "for fun" file like Partn.py or Partn.xlsx
        Sometimes there is an extra "Alternative/Optimized" file like PartnAlternative.ps1 
    Code:
        Reset variables and terminal output
        StopWatch
        Variable initialisation
        Input
            Demo/UnitTest
            Real
        Functions and or Loops
        Calculated Answer
        # Correct answer = xyz (abc for testdata) + Speed/Resource-Analysis

        Sometimes there will be stopwatch-output or other "debug-info" written but that will mostly be commented out ones the code is working
        I almost never hardcode values, especially not when they can/should be gathered from the input. Exceptions are for Speed/Resource-Analysis