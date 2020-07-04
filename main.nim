import rdstdin, strformat, strutils, osproc, os
import src/setup, src/getVars, src/gitBranch

# OS dependent vars
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

# ansi vars
const
    black: string = "\x1b[30m"
    red: string = "\x1b[31m"
    green: string = "\x1b[32m"
    yellow: string = "\x1b[33m"
    blue: string = "\x1b[34m"
    megenta: string = "\x1b[35m"
    cyan: string = "\x1b[36m"
    white: string = "\x1b[37m"
    reset: string = "\x1b[0m"
    clear: string = "\x1b[2J"

proc main() =
    while true:
        let result: bool = readLineFromStdin(&"[{cyan}{user} {blue}{getCurrentDir().split(dirSplit)[^1]}{green}{gitBranch()}{reset}] {megenta}--> {reset}", line=line)
        let command: string = line.split(" ")[0]
        let args: seq[string] = getVars(line.split(" ")[1..^1])
        case command
        of "exit": quit(0)
        of "cd":
            try: setCurrentDir(args[0])
            except IndexError:
                try: setCurrentDir(getHomeDir()) except OSError: discard
            except OSError: stdout.write("\nThe directory does not exist!")
        # of "clear":
        #     echo clear
        else: stdout.write(execProcess(line))
        if not result: quit(0)

when isMainModule:
    setup(RunningOn, user, shellFormat)
    main()
