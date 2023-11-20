#!/usr/bin/env nix-shell
#!nix-shell -i bash -p coreutils -p playerctl -p pulseaudio

# input map considerations
# - using compound actions causes delays.
#   e.g. if volup->volup is a distinct action from volup, then single-volup action is forced to wait the maximum button delay.
# - actions which are to be responsive should therefore have a dedicated key.
# - a dedicated "kill" combo is important for unresponsive fullscreen apps, because appmenu doesn't show in those
#   - although better may be to force appmenu to show over FS apps
# - bonsai mappings are static, so buttons can't benefit from non-compounding unless they're mapped accordingly for all lock states
#   - this limitation could be removed, but with work
#
# proposed future design:
# - when unlocked:
#   - volup-release   -> app menu
#     - volup-hold    -> WM menu
#   - voldown-release -> toggle keyboard
#     - voldown-hold  -> terminal
#   - pow-volup xN    -> volume up
#   - pow-voldown xN  -> volume down
#   - pow-x2          -> screen off
#   - pow-hold -> kill app
# - when screenoff:
#   - volup    -> volume up
#   - voldown  -> volume down
#   - pow-x1   -> screen on
#   - pow-x2   -> toggle player
#   - pow-volup -> seek +30s
#   - pow-voldown -> seek -10s
# benefits:
# - volup and voldown are able to be far more responsive
#   - which means faster vkbd, menus, volume adjustment (when locked)
# - less mental load than the chording-based approach (where i hold power to adjust volume)
# - less risk due to not chording the power button
# drawbacks:
# - volup/down actions are triggered by the release instead of the press; slight additional latency for pulling open the keyboard
#   - moving the WM menu into the top-level menu could allow keeping voldown free of complication

# increments to use for volume adjustment
VOL_INCR_1=5
VOL_INCR_2=10

# replicating the naming from upstream sxmo_hook_inputhandler.sh...
ACTION="$1"
STATE=$(cat "$SXMO_STATE")


handle_with() {
  echo "sxmo_hook_inputhandler.sh: STATE=$STATE ACTION=$ACTION: handle_with: $@"
  "$@"
  exit 0
}

# handle_with_state_toggle() {
#   # - unlock,lock => screenoff
#   # - screenoff => unlock
#   #
#   # probably not handling proximity* correctly here
#   case "$STATE" in
#     *lock)
#       respond_with sxmo_state.sh set screenoff
#     *)
#       respond_with sxmo_state.sh set unlock
#   esac
# }

# state is one of:
# - "unlock" => normal operation; display on and touchscreen on
# - "screenoff" => display off and touchscreen off
# - "lock" => display on but touchscreen disabled
# - "proximity{lock,unlock}" => intended for when in a phone call

if [ "$STATE" = "unlock" ]; then
  case "$ACTION" in
    # powerbutton_one: intentional default to no-op
    # powerbutton_two: intentional default to screenoff
    "powerhold")
      # power thrice: kill active window
      handle_with sxmo_killwindow.sh
      ;;

    "volup_one")
      # volume up once: app-specific menu w/ fallback to SXMO system menu
      handle_with sxmo_appmenu.sh
      ;;

    "voldown_one")
      # volume down once: toggle keyboard
      handle_with sxmo_keyboard.sh toggle
      ;;

    "powertoggle_volup")
      # power -> volume up: DE menu
      handle_with sxmo_wmmenu.sh
      ;;
    "powertoggle_voldown")
      # power -> volume down: launch terminal
      handle_with sxmo_terminal.sh
      ;;
  esac
fi

if [ "$STATE" = "screenoff" ]; then
  case "$ACTION" in
    "powerbutton_two")
      # power twice => toggle media player
      handle_with playerctl play-pause
      ;;
    "powerhold")
      # power toggle during deep sleep often gets misread as power hold, so treat same
      handle_with sxmo_state.sh set unlock
      ;;
    "powertoggle_volup"|"powerhold_volup")
      # power -> volume up: seek forward
      handle_with playerctl position 30+
      ;;
    "powertoggle_voldown"|"powerhold_voldown")
      # power -> volume down: seek backward
      handle_with playerctl position 10-
      ;;
  esac
fi

# default actions
case "$ACTION" in
  "powerbutton_one")
    # power once => unlock
    handle_with sxmo_state.sh set unlock
    ;;
  "powerbutton_two")
    # power twice => screenoff
    handle_with sxmo_state.sh set screenoff
    ;;
  # powerbutton_three: intentional no-op because overloading the kill-window handler is risky

  "volup_one")
    handle_with pactl set-sink-volume @DEFAULT_SINK@ +"$VOL_INCR_1%"
    ;;
  "voldown_one")
    handle_with pactl set-sink-volume @DEFAULT_SINK@ -"$VOL_INCR_1%"
    ;;

  # HOLD power button and tap volup/down to adjust volume
  "powerhold_volup")
    handle_with pactl set-sink-volume @DEFAULT_SINK@ +"$VOL_INCR_1%"
    ;;
  "powerhold_voldown")
    handle_with pactl set-sink-volume @DEFAULT_SINK@ -"$VOL_INCR_1%"
    ;;
esac


handle_with echo "no-op"
