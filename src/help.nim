import tables
proc help*(item:string):string = 
    const descriptions = {
        "cd": "Change the directory. Syntax: `cd directory_path`.",
        "exit": "Quit the shell with an exit status of 0. Syntax: `exit`. Custom exit codes will be implemented in the future.",
        "export": "Export environment variables (not shell variables). Syntax: `export VARIABLE_NAME=value` (You may use no quotes, single quotes, or double quotes)."
    }.toTable
    if item in descriptions: return descriptions[item]
    else: return ""