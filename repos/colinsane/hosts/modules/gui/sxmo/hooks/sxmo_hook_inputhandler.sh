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
# example of a design which considers these things:
# - when unlocked:
#   - volup toggle  -> app menu
#   - voldown press -> keyboard
#   - voldown hold  -> terminal
#   - power x2      -> screenoff
#   - hold power    -> kill app
# - when locked:
#   - volup tap     -> volume up
#   - volup hold    -> media seek forward
#   - voldown tap   -> volume down
#   - voldown hold  -> media seek backward
#   - power x1      -> screen on
#   - power x2      -> play/pause media
# some trickiness allows for media controls in unlocked mode:
#   - volup tap     -> enter media mode
#     - i.e. in this state, vol tap/hold is mapped to volume/seek
#     - if, after entering media mode, no more taps occur, then we trigger the default app-menu action
# limitations/downsides:
# - power mappings means phone is artificially slow to unlock.
# - media controls when unlocked have quirks:
#   - mashing voldown to decrease the volume will leave you with a toggled keyboard.
#   - seeking backward isn't possible except by first tapping volup.


# increments to use for volume adjustment
VOL_INCR=5

# replicating the naming from upstream sxmo_hook_inputhandler.sh...
ACTION="$1"
STATE=$(cat "$SXMO_STATE")

noop() {
  true
}

handle_with() {
  echo "sxmo_hook_inputhandler.sh: STATE=$STATE ACTION=$ACTION: handle_with: $@"
  "$@"
  exit 0
}


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

    "volup_tap_1")
      # swallow: this could be the start to a media control (multi taps / holds),
      # or it could be just a single tap -> release, handled next/below
      handle_with noop
      ;;
    "volup_1")
      # volume up once: app-specific menu w/ fallback to SXMO system menu
      handle_with sxmo_appmenu.sh
      ;;

    "voldown_start")
      # volume down once: toggle keyboard
      handle_with sxmo_keyboard.sh toggle
      ;;
    "voldown_hold_2")
      # hold voldown to launch terminal
      # note we already triggered the keyboard; that's fine: usually keyboard + terminal go together :)
      # voldown_hold_1 frequently triggers during short taps meant only to reveal the keyboard,
      # so prefer a longer hold duration
      handle_with sxmo_terminal.sh
      ;;
    "voldown_tap_1")
      # swallow, to prevent keyboard from also triggering media controls
      handle_with noop
      ;;
    voldown_hold_*)
      # swallow, to prevent terminal from also triggering media controls
      handle_with noop
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

  volup_tap*|modal_volup_tap*)
    handle_with pactl set-sink-volume @DEFAULT_SINK@ +"$VOL_INCR%"
    ;;
  voldown_tap*|modal_voldown_tap*)
    handle_with pactl set-sink-volume @DEFAULT_SINK@ -"$VOL_INCR%"
    ;;

  volup_hold*|modal_volup_hold*)
    handle_with playerctl position 30+
    ;;
  voldown_hold*|modal_voldown_hold*)
    handle_with playerctl position 10-
    ;;
esac


handle_with noop
