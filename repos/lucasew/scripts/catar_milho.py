#!/usr/bin/env nix-shell
#!nix-shell -i python -p python3Packages.pyautogui libnotify

import subprocess
import pyautogui
from time import sleep
from random import random, choice

SYMBOLS=list(map(chr, [*range(ord('a'), ord('z')), *range(ord('A'), ord('Z')), *range(ord('0'), ord('9'))]))
def randomize_time(baseline, variation):
    offset = variation * random()
    offset = (offset * 2) - offset
    return baseline + offset

while True:
    t = randomize_time(5, 3)
    subprocess.check_output(["notify-send", f"tecla vai ser mandada em {str(t)}s"])
    sleep(t)
    pyautogui.write(choice(SYMBOLS))

