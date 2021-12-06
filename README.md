https://deltanoffice365.sharepoint.com/sites/dev/SitePages/Advent-of-Code-2021.aspx
https://teams.microsoft.com/_#/conversations/19:82824b8c67ac4964870839c6f6cb22dc@thread.v2?ctx=chat
https://adventofcode.com/2021/leaderboard/private/view/676063

Useful for measuring performance:
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $stopwatch.Elapsed

Most code follows these principle:
    Files:
        Day-Part[-Demo]-Input.txt
        Day-Part.ps1
        Sometimes there is an extra "for fun" file like Day-Part.py or Day-Part.xlsx
    Code:
        StopWatch
        Variable initialisation
        Input
            Demo/UnitTest
            Real
        Functions and or Loops
        Calculated Answer
        CorrectAnswer + Speed/Resource-Analysis

        Sometimes there will be stopwatch-output or other "debug-info" written but that will mostly be commented out ones the code is working
        I almost never hardcode values, especially not when they can/should be gathered from the input. Exceptions are for Speed/Resource-Analysis