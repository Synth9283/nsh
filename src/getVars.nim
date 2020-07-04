import os

proc getVars*(args: seq[string]): seq[string] =
    result = @[]
    for arg in args:
        if arg[0] == '$': result.add(getEnv(arg[1..^1]))
        else: result.add(arg)
    if result == @[]: return args
    else: return result
