import os

proc setup*(RunningOn: string, user: var string, shellFormat: var string) =
    case RunningOn
    of "windows": user = getEnv("USERNAME")
    of "linux": user = getEnv("USER")
    of "macos": user = getEnv("USER")
    of "other": discard
    else: discard
