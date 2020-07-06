import os, strutils, osproc, tables
proc help(item:string):string = 
    const descriptions = {
        "cd": "Change the directory. Syntax: `cd directory_path`.",
        "exit": "Quit the shell with an exit status of 0. Syntax: `exit`. Custom exit codes will be implemented in the future.",
        "export": "Export environment variables (not shell variables). Syntax: `export VARIABLE_NAME=value` (You may use no quotes, single quotes, or double quotes)."
    }.toTable
    if item in descriptions: return descriptions[item]
    else: return ""
proc runLine*(command:string, line:string, args:seq[string]):string = 
    case command
    of "exit": quit(0)
    of "cd":
        try: setCurrentDir(args[0])
        except IndexError:
            try: setCurrentDir(getHomeDir()) except OSError: discard
        except OSError: return "The directory specified does not exist. See `help cd`."
    of "export":
        if args == @[]: return "Nothing was provided to export. See `help export`"
        else:
            var envVar: seq[string] = args[0].split("=")
            var envVarVal: string = envVar[1]
            if envVarVal.startsWith("'") and envVarVal.endsWith("'"): envVarVal.removePrefix("'"); envVarVal.removeSuffix("'")
            elif envVarVal.startsWith("\"") and envVarVal.endsWith("\""): envVarVal.removePrefix("\""); envVarVal.removeSuffix("\"")
            try: putEnv(envVar[0], envVarVal) except: return "There was an error setting the environment variable, please check `help export`"
    of ".", "source":
        for script in args:
            for line in readFile(script).split("\n"):
                let command: string = line.split(" ")[0]
                stdout.write(runLine(command, line, args))
    of "help", "man":
       var hp = help(args.join(" "))
       if hp == "": echo "No help page found for " & args.join(" ")
       else: echo hp
    else: stdout.write(execProcess(line)); stdout.flushFile()