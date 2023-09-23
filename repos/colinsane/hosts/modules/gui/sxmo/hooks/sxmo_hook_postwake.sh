#!/bin/sh

# the default sxmo_postwake handler checks if the modem is offline
# and if so installs a wakelock to block suspend for 30s.
# that's a questionable place to install that logic, and i want to keep stuff
# out of the wake-from-sleep critical path, so i'm overriding this hook to disable that.
