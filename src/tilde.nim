import strutils, os
proc tilde*(path: string): string =
  var npath = path & "/"
  let home = getHomeDir()
  if npath.startsWith(home):
    result = "~/" & path.split(home)[1]
  else:
    result = path