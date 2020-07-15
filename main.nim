import strformat, strutils, os
import src/setup, src/getArgs, src/colorsAnsi, src/homeDir, src/gitBranch, src/runLine, linenoise

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
    user: string
    shellFormat: string

let cnsh = getHomeDir() & ".nshrc"
let history = getHomeDir() & ".nsh_history"

proc main() =

    if fileExists(cnsh): 
        for line in readFile(cnsh).split("\n"):
            let command: string = line.split(" ")[0]
            let args: seq[string] = getArgs(line.split(" ")[1..^1])
            runLine(command, line, args)
    if fileExists(history):
        historyAdd(history.cstring)
    while true:
        var promptchar: string
        if existsEnv("PROMPTCHAR"): promptchar = getEnv("PROMPTCHAR")
        else: promptchar = ">"
        let linec = linenoise.readLine(&"{blue}{homeDir(getCurrentDir())}{green}{gitBranch()}{magenta} {promptchar} {resetc}")
        let line = $linec
        historyAdd(linec)
        let command: string = line.split(" ")[0]
        let args: seq[string] = getArgs(line.split(" ")[1..^1])
        runLine(command, line, args)

when isMainModule:
    setup(RunningOn, user, shellFormat)
    main()
    discard historySave(history)
