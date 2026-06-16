#!/bin/bash

# Script to toggle the mute status of the default sink
pactl set-sink-mute @DEFAULT_SINK@ toggle