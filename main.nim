import rdstdin, strformat, strutils, osproc, os
import src/setup, src/getVars, src/git

# OS dependent variables for windows, macOS, Linux, and other operating systems (assumed to be UNIX comliant)
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
    magenta: string = "\x1b[35m"
    cyan: string = "\x1b[36m"
    white: string = "\x1b[37m"
    reset: string = "\x1b[0m"
    clear: string = "\x1b[2J"

proc main() =
    while true:
        let result: bool = readLineFromStdin(&"{blue}{getCurrentDir()}{reset} [{green}{gitBranch().strip()}{gitStatus()}{reset}] {magenta}--> {reset}", line=line)
        let command: string = line.split(" ")[0]
        let args: seq[string] = getVars(line.split(" ")[1..^1])
        case command
        of "exit": quit(0)
        of "cd":
            try: setCurrentDir(args[0])
            except IndexError:
                try: setCurrentDir(getHomeDir()) except OSError: discard
            except OSError: echo("The directory specified does not exist. See `help cd`.")
        of "export":
            if args.len == 0:
                echo("Nothing was provided to export. See `help export`")
            var stuff = args[0].split("=")
            if stuff[1].startsWith("'") and stuff[1].endsWith("'"):
                stuff[1].removePrefix("'"); stuff[1].removeSuffix("'")
            elif stuff[1].startsWith("\"") and stuff[1].endsWith("\""):
                stuff[1].removePrefix("\""); stuff[1].removeSuffix("\"")
            try:
                putEnv(stuff[0], stuff[1])
            except:
                echo("There was an error setting the environment variable, please check `help export`")
        else: stdout.write(execProcess(line))
        if not result: quit(0)

when isMainModule:
    setup(RunningOn, user, shellFormat)
    main()
