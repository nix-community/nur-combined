#!/usr/bin/env bash
set -euo pipefail
scripts=$1

# Each script runs with writeShellApplication's strict options. Mock only the
# hardware/notification commands so tests cannot change real devices or notify.
dunstify() { printf '%s\n' "$*"; }
wpctl() {
  [[ ${FAIL_WPCTL:-0} == 0 ]] || return 1
  printf '%s\n' "${VOLUME_DATA:-Volume: 0.50}"
}
brightnessctl() {
  [[ ${FAIL_BRIGHTNESS:-0} == 0 ]] || return 1
  printf '%s\n' 'intel_backlight,backlight,500,50%,1000'
}
export -f dunstify wpctl brightnessctl
run_script() { bash -euo pipefail "$scripts/$1"; }

mkdir -p power/BAT0 peripheral/mouse empty
printf 'Battery\n' > power/BAT0/type
printf 'System\n' > power/BAT0/scope
printf '0\n' > power/BAT0/capacity
printf 'Discharging\n' > power/BAT0/status
cp power/BAT0/* peripheral/mouse/
printf 'Device\n' > peripheral/mouse/scope

[[ $(POWER_SUPPLY_ROOT="$PWD/empty" run_script battery.sh) == '' ]]
[[ $(POWER_SUPPLY_ROOT="$PWD/peripheral" run_script battery.sh) == '' ]]
[[ $(POWER_SUPPLY_ROOT="$PWD/power" run_script battery.sh) == *'Battery: 0% (Discharging)' ]]
printf '100\n' > power/BAT0/capacity
printf 'Full\n' > power/BAT0/status
[[ $(POWER_SUPPLY_ROOT="$PWD/power" run_script battery.sh) == *'Battery: 100% (Full)' ]]

[[ $(run_script audio.sh) == *'Volume: 50%' ]]
[[ $(VOLUME_DATA='Volume: 0.50 [MUTED]' run_script audio.sh) == *'Volume mute' ]]
[[ $(VOLUME_DATA='Volume: 1.50' run_script audio.sh) == *'Volume: 150%' ]]
if FAIL_WPCTL=1 run_script audio.sh; then exit 1; fi
if VOLUME_DATA='invalid' run_script audio.sh; then exit 1; fi
[[ $(run_script brightness.sh) == *'Brightness: 50%' ]]
if FAIL_BRIGHTNESS=1 run_script brightness.sh; then exit 1; fi

[[ $(run_script cpu-mem.sh) == *'CPU:'*'RAM:'* ]]
[[ $(run_script date.sh) == *'-a osd -u low'* ]]
printf 'Dunst behavior checks passed\n'
