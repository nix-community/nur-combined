#!/bin/bash
pkill quickshell
hyprctl reload

sleep 1

quickshell -c noctalia-shell
