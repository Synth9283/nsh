import osproc, os

proc gitBranch*(): string =
    if existsDir(".git"): result = "["&execProcess("git rev-parse --abbrev-ref HEAD")[0..^2]&"]"
    else: result = ""
    return result
