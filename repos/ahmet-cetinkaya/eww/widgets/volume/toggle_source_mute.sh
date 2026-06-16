#!/bin/bash

# Script to toggle the mute status of the default source (microphone)
pactl set-source-mute @DEFAULT_SOURCE@ toggle