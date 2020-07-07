import strutils, os
from sugar import dup
proc expand*(s: seq[string]): seq[string] = 
    var scopy = s
    for index, item in scopy:
        if item.startsWith("$"): scopy[index] = getEnv(item.dup(removePrefix("$")))
    return scopy