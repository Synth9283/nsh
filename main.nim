import rdstdin, strformat, strutils, osproc, os
import src/setup

# check the os
when defined(windows):
    const RunningOn = "windows"
when defined(linux):
    const RunningOn = "linux"
when defined(mac):
    const RunningOn = "macos"
when defined(other):
    const RunningOn = "other"

# vars
var line: string
var user: string
var shellFormat: string

proc main() =
    while true:
        let result: bool = readLineFromStdin(&"[{user}] --> ", line=line)
        let command: string = line.split(" ")[0]
        let args: seq[string] = line.split(" ")[1..^1]
        case command
        of "exit": quit(0)
        of "cd": setCurrentDir(args[0])
        else: echo execProcess(line)
        if not result: quit(0)

when isMainModule:
    setup(RunningOn, user, shellFormat)
    main()
