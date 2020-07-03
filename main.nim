import rdstdin, osproc, strformat
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
        case line
        of "exit": quit(0)
        else: echo execProcess(line)
        if not result: quit(0)

when isMainModule:
    setup(RunningOn, user, shellFormat)
    main()
