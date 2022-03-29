#!/usr/bin/env bash
# Example on how to start certain programs on certain tags and monitors
# in instantWM.
#
# Link to ~/.config/instantos/autostart.sh (must be executable).

for cmd in wmctrl xrandr; do
   command -v "$cmd" 1>&2 2>/dev/null || 
      { echo "Please install '$cmd'!" 1>&2; exit; }
done

startwin() {
   # Wait for window to start.
   #
   # Note: Each program must not already be started and only be used
   # once with this function.
   if wmctrl -l -x | grep -Fi "$1"; then return; fi
   echo "Starting $1..."
   $1 &
   echo "Waiting for $1"
   for x in {15..1}; do
      echo $x; wmctrl -l -x  # debug
      if wmctrl -l -x | grep -Fi "${2:-1}"; then
         sleep 1
         return
      fi
      sleep 1
   done
   echo "Timed out waiting for '$1'."
   exit 1
}

if command -v PERScom 2>/dev/null; then
    while ! PERScom 2 2 on; do sleep 2 done &
fi

instantwmctrl animated 1  # turn of window manager animations
instantwmctrl tag 1
startwin firefox

# Wait for second monitor
while ! xrandr | grep "Virtual2 connected"; do
   sleep 1
done

instantwmctrl focusmon
instantwmctrl tag 1
startwin Discord
sleep 2
startwin telegram-desktop

instantwmctrl tag 2
startwin slack

instantwmctrl tag 3
startwin signal-desktop signal

instantwmctrl tag 4
startwin thunderbird

instantwmctrl tag 5
startwin kitty

instantwmctrl  tag 6
firefox &
sleep 2

instantwmctrl tag 1
instantwmctrl focusmon

iconf -i noanimations || instantwmctrl animated 3  # re-enable animations if configured

