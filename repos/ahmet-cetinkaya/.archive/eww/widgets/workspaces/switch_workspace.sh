#!/bin/bash

# Script to switch to a specific workspace (takes workspace ID as argument)
if [ -n "$1" ]; then
    hyprctl dispatch workspace "$1"
else
    echo "Error: No workspace ID provided"
fi