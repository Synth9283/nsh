import os, strutils, osproc, help, colorsAnsi
proc runLine*(command:string, line:string, args:seq[string]) = 
    case command
    of "exit": quit(0)
    of "cd":
        try: setCurrentDir(args[0])
        except IndexError:
            try: setCurrentDir(getHomeDir())
            except OSError: discard
        except OSError: echo "The directory specified does not exist. See `help cd`.".err
    of "export":
        if args == @[]: echo "Nothing was provided to export. See `help export`".err
        elif args.len == 1: echo "No value provided for environment variable.".err
        else:
            var envVar: seq[string] = args[0].split("=")
            var envVarVal: string = envVar[1]
            if envVarVal.startsWith("'") and envVarVal.endsWith("'"): envVarVal.removePrefix("'"); envVarVal.removeSuffix("'")
            elif envVarVal.startsWith("\"") and envVarVal.endsWith("\""): envVarVal.removePrefix("\""); envVarVal.removeSuffix("\"")
            try: putEnv(envVar[0], envVarVal) 
            except: echo "There was an error setting the environment variable, please check `help export`".err
    of ".", "source":
        for script in args:
            for line in readFile(script).split("\n"):
                let command: string = line.split(" ")[0]
                runLine(command, line, args)
    of "help", "man":
       var hp = help(args.join(" "))
       if hp == "": echo ("No help page found for " & args.join(" ") & ".").err
       else: echo hp
    else: stdout.write(execProcess(line)); stdout.flushFile()