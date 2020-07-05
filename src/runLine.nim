import os, strutils, osproc
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
    else: stdout.write(execProcess(line)); stdout.flushFile()