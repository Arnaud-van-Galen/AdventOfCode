#### Links
* [Aankondiging van Delta-N](https://deltanoffice365.sharepoint.com/sites/dev/SitePages/Advent-of-Code-2021.aspx)
* [Doe mee via](https://adventofcode.com/2021)
* [Meld je aan voor het private leaderbord](https://adventofcode.com/2021/leaderboard/private/view/676063)
* [Chat mee](https://teams.microsoft.com/_#/conversations/19:82824b8c67ac4964870839c6f6cb22dc@thread.v2?ctx=chat)
* [Deel je code](https://github.com/Arnaud-van-Galen/AdventOfCode)
* [En kijk ook naar die van anderen](https://deltanoffice365-my.sharepoint.com/:x:/g/personal/ferdivt_delta-n_nl/EeWDEAWJeDlBkAlJDFIxghABMyVxxfpAVssXctUe0iYn2g)
---
#### Code tips and tricks
- Useful for measuring performance:
    - `$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()`
    - `Write-Host "Time for calculating:", $stopwatch.Elapsed.TotalSeconds`
- Useful for making sure that variables and output are reset:
     - ~~`Get-Variable | Remove-Variable -ErrorAction SilentlyContinue`~~
     - `[System.Console]::Clear()`
    - And [more useful tips-and-tricks on how to see/reset your own variables only by using some profile code](https://4sysops.com/archives/display-and-search-all-variables-of-a-powershell-script-with-get-variable/)
        - Summary: Add the below function to the below files and call it by running Get-MyVariables
        `$AutomaticVariables = Get-Variable`
        `function Get-MyVariables { Compare-Object (Get-Variable) $AutomaticVariables -Property Name -PassThru | Where-Object -Property Name -ne "AutomaticVariables" }`
            - "C:\Users\Arnaud\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
            - "C:\Users\Arnaud\OneDrive\Documents\PowerShell\Microsoft.VSCode_profile.ps1"
        
---
#### Principles
- Files:
    - yyyy\Daydd\Data[Demo].txt
    - yyyy\Daydd\Partn.ps1
    - Sometimes there is an extra "for fun" file like Partn.py or Partn.xlsx
    - Sometimes there is an extra "Alternative/Optimized" file like PartnAlternative.ps1 
- Code:
    - Reset variables and terminal output
    - StopWatch
    - Variable initialisation
    - Input
        - Demo/UnitTest
        - Real
    - Functions and or Loops
    - Calculated Answer
    - \# Correct answer = xyz (abc for testdata) + Speed/Resource-Analysis
- Other:
    - Sometimes there will be stopwatch-output or other "debug-info" written but that will mostly be commented out ones the code is working
    - I almost never hardcode values, especially not when they can/should be gathered from the input. Exceptions are for Speed/Resource-Analysis