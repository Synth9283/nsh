# This module implements ANSI colors that can be imported (move to table or ref object later) and then printed.
const
    black*: string = "\x1b[30m"
    red*: string = "\x1b[31m"
    green*: string = "\x1b[32m"
    yellow*: string = "\x1b[33m"
    blue*: string = "\x1b[34m"
    magenta*: string = "\x1b[35m"
    cyan*: string = "\x1b[36m"
    white*: string = "\x1b[37m"
    resetc*: string = "\x1b[0m"
    clear*: string = "\x1b[2J"

proc err*(s:string):string = return red & s & resetc