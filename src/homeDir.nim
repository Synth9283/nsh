import strutils, os

proc homeDir*(path: string): string =
    let home = getHomeDir()
    if path.startsWith(home): result = "~/"&path.split(home)[1]
    else: result = path
