#!/usr/bin/env bash

IFS=',' read -r header percent _ <<<"$(acpi -b)"
state=${header#*: }
pct=${percent//[^0-9]/}

dis_icons=(󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹)
chg_icons=(󰢜 󰂆 󰂇 󰂈 󰢝 󰂉 󰢞 󰂊 󰂋 󰂅)

# bucket index = pct/10, max 9
idx=$((pct / 10))
((idx > 9)) && idx=9

case "$state" in
Charging) icon=${chg_icons[idx]} ;;
Full) icon=${dis_icons[9]} ;;
*) icon=${dis_icons[idx]} ;;
esac

dunstify -a osd -u low "${icon} Battery: ${pct}% (${state})"
