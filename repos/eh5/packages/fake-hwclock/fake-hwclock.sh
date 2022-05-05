# shellcheck shell=bash

THISFILE=$0
STATEFILE=${STATEFILE-"/var/lib/fake-hwclock.state"}

statetime() {
  stat -c %Y "$STATEFILE" 2>/dev/null || echo 0
}

loadclock() {
  local savedtime=$(statetime)
  if [ $(date +%s) -lt $savedtime ]; then
    echo "Restoring saved system time"
    date -s @$savedtime
  else
    echo "Not restoring old system time"
  fi
}

saveclock() {
  local savedtime=$(statetime)
  if [ $(date +%s) -gt $savedtime ]; then
    echo "Saving current time."
    touch "$STATEFILE"
  else
    echo "Not saving outdated system time"
  fi
}

case "$1" in
load)
  loadclock
  ;;
set)
  echo "'set' is deprecated, use 'load' instead."
  echo "Consider using the systemd timer unit fake-hwclock-save.timer"
  loadclock
  ;;
save)
  saveclock
  ;;
*)
  echo "Usage: $THISFILE {load|save}"
  exit 1
  ;;
esac
