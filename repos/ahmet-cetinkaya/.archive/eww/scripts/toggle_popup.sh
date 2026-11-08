#!/bin/bash

# Script to toggle popup windows with closer overlay
# Usage: toggle_popup.sh <popup_name>

popup_name=$1

if eww windows | grep -q "$popup_name"; then
  eww close "$popup_name"
else
  eww open closer
  eww open "$popup_name"
fi