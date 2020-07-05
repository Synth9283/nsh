import strformat, strutils, osproc, os
import src/setup, src/getVars, src/gitBranch, src/homeDir, src/colorsAnsi, src/runLine

# OS dependent variables for Windows, MacOS, Linux, and other operating systems (assumed to be UNIX comliant)
when defined(windows):
    const
        RunningOn: string = "windows"
        dirSplit: string = r"\"
when defined(linux):
    const
        RunningOn: string = "linux"
        dirSplit: string = "/"
when defined(mac):
    const
        RunningOn: string = "macos"
        dirSplit: string = "/"
when defined(other): 
    const
        RunningOn: string = "other"
        dirSplit: string = "/" 

# shell vars
var
    line: string
    user: string
    shellFormat: string

proc main() =
    var cnsh = getHomeDir() & ".learconfig.nsh"
    if fileExists(cnsh): 
        for line in readFile(cnsh).split("\n"):
            let command: string = line.split(" ")[0]
            let args: seq[string] = getVars(line.split(" ")[1..^1])
            stdout.write(runLine(command, line, args))
    while true:
        var promptchar: string
        if existsEnv("PROMPTCHAR"): promptchar = getEnv("PROMPTCHAR")
        else: promptchar = ">"
        stdout.write(&"{blue}{homeDir(getCurrentDir())}{green}{gitBranch()}{magenta} {promptchar} {resetc}")
        stdout.flushFile()
        let result: bool = stdin.readLine(line)
        let command: string = line.split(" ")[0]
        let args: seq[string] = getVars(line.split(" ")[1..^1])
        if not line.endsWith("^C"): stdout.write(runLine(command, line, args))
        elif not result: quit(0)

when isMainModule:
    setup(RunningOn, user, shellFormat)
    main()
