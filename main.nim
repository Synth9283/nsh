import rdstdin, strformat, strutils, osproc, os
import src/setup, src/getVars

# check the os
when defined(windows):
    const RunningOn = "windows"
    const homeDir = "USERPROFILE"
when defined(linux):
    const RunningOn = "linux"
    const homeDir = "HOME"
when defined(mac):
    const RunningOn = "macos"
    const homeDir = "HOME"
when defined(other):
    const RunningOn = "other"
    const homeDir = "/"

# vars
var line: string
var user: string
var shellFormat: string

proc main() =
    while true:
        let result: bool = readLineFromStdin(&"[{user}] --> ", line=line)
        let command: string = line.split(" ")[0]
        let args: seq[string] = getVars(line.split(" ")[1..^1])
        case command
        of "exit": quit(0)
        of "cd":
            try: setCurrentDir(args[0])
            except IndexError:
                try: setCurrentDir(getEnv(homeDir)) except OSError: discard
            except OSError: echo "The directory does not exist!"
        else: echo execProcess(line)
        if not result: quit(0)

when isMainModule:
    setup(RunningOn, user, shellFormat)
    main()
