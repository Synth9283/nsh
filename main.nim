import strformat, strutils, osproc, os
import src/setup, src/getVars, src/gitBranch, src/homeDir, src/colorsAnsi

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
    while true:
        stdout.write(&"{blue}{homeDir(getCurrentDir())}{green}{gitBranch()}{magenta} > {resetc}")
        stdout.flushFile()
        let result: bool = stdin.readLine(line)
        let command: string = line.split(" ")[0]
        let args: seq[string] = getVars(line.split(" ")[1..^1])
        if not line.endsWith("^C"):
            case command
            of "exit": quit(0)
            of "cd":
                try: setCurrentDir(args[0])
                except IndexError:
                    try: setCurrentDir(getHomeDir()) except OSError: discard
                except OSError: echo("The directory specified does not exist. See `help cd`.")
            of "export":
                if args == @[]: echo("Nothing was provided to export. See `help export`")
                else:
                    var envVar: seq[string] = args[0].split("=")
                    var envVarVal: string = envVar[1]
                    if envVarVal.startsWith("'") and envVarVal.endsWith("'"): envVarVal.removePrefix("'"); envVarVal.removeSuffix("'")
                    elif envVarVal.startsWith("\"") and envVarVal.endsWith("\""): envVarVal.removePrefix("\""); envVarVal.removeSuffix("\"")
                    try: putEnv(envVar[0], envVarVal) except: echo("There was an error setting the environment variable, please check `help export`")
            else: stdout.write(execProcess(line)); stdout.flushFile()
        elif not result: quit(0)

when isMainModule:
    setup(RunningOn, user, shellFormat)
    main()
