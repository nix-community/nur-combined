#!/bin/bash

# Script to close all open popup windows and the closer window itself
# This script is called when the closer widget is clicked

# Close each window only if it's open
# Note: We can't easily check if a window is open in EWW, so we'll close them one by one
# and ignore errors for windows that aren't open

eww close volume-popup 2>/dev/null
eww close tray-popup 2>/dev/null
eww close clock-panel-popup 2>/dev/null
eww close power-menu 2>/dev/null
eww close closer 2>/dev/null
