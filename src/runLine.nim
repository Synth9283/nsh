import os, strutils, osproc, help, colorsAnsi, expand
proc runLine*(command:string, line:string, args:seq[string]) = 
    var eargs = expand(args)
    case command
    of "exit": quit(0)
    of "cd":
        try:
            if eargs[0] == "~": setCurrentDir(getHomeDir())
            else: setCurrentDir(eargs[0])
        except IndexError:
            try: setCurrentDir(getHomeDir())
            except OSError: discard
        except OSError: echo "The directory specified does not exist. See `help cd`.".err
    of "export":
        if eargs == @[]: echo "Nothing was provided to export. See `help export`".err
        else:
            var envVar: seq[string] = eargs[0].split("=")
            if envVar.len == 1: putEnv(envVar[0], "")
            else:
                var envVarVal: string = envVar[1]
                if envVarVal.startsWith("'") and envVarVal.endsWith("'"): envVarVal.removePrefix("'"); envVarVal.removeSuffix("'")
                elif envVarVal.startsWith("\"") and envVarVal.endsWith("\""): envVarVal.removePrefix("\""); envVarVal.removeSuffix("\"")
                try: putEnv(envVar[0], envVarVal) 
                except: echo "There was an error setting the environment variable, please check `help export`".err
    of ".", "source":
        for script in eargs:
            for line in readFile(script).split("\n"):
                let command: string = line.split(" ")[0]
                runLine(command, line, eargs)
    of "help", "man":
       var hp = help(eargs.join(" "))
       if hp == "": echo ("No help page found for " & eargs.join(" ") & ".").err
       else: echo hp
    else: stdout.write(execProcess(line)); stdout.flushFile()