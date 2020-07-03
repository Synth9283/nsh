import rdstdin, strformat, strutils, osproc, os
import src/setup, src/getVars

# check the os
when defined(windows):
    const RunningOn = "windows"
    const homeDir = "USERPROFILE"
    const dirSplit = r"\"
when defined(linux):
    const RunningOn = "linux"
    const homeDir = "HOME"
    const dirSplit = "/"
when defined(mac):
    const RunningOn = "macos"
    const homeDir = "HOME"
    const dirSplit = "/"
when defined(other):
    const RunningOn = "other"
    const homeDir = "/"
    const dirSplit = "/"

# vars
var line: string
var user: string
var shellFormat: string

proc main() =
    while true:
        let result: bool = readLineFromStdin(&"[{user} {getCurrentDir().split(dirSplit)[^1]}] --> ", line=line)
        let command: string = line.split(" ")[0]
        let args: seq[string] = getVars(line.split(" ")[1..^1])
        case command
        of "exit": quit(0)
        of "cd":
            try: setCurrentDir(args[0])
            except IndexError:
                try: setCurrentDir(getEnv(homeDir)) except OSError: discard
            except OSError: stdout.write("The directory does not exist!")
        else: stdout.write(execProcess(line))
        if not result: quit(0)

when isMainModule:
    setup(RunningOn, user, shellFormat)
    main()
