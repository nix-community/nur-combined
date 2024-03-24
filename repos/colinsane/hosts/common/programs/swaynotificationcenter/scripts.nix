# this file defines the `scripts` entry within ~/.config/swaync/config.json.
# it describes special things to do in response to specific notifications,
# e.g. sound a ringer when we get a call, ...
{ pkgs }:
let
  fbcli-wrapper = pkgs.writeShellApplication {
    name = "swaync-fbcli";
    runtimeInputs = [
      pkgs.feedbackd
      pkgs.procps  # for pkill
      pkgs.swaynotificationcenter
    ];
    text = ''
      # if in Do Not Disturb, don't do any feedback
      # TODO: better solution is to actually make use of feedbackd profiles.
      #       i.e. set profile to `quiet` when in DnD mode
      if [ "$SWAYNC_URGENCY" != "Critical" ] && [ "$(swaync-client --get-dnd)" = "true" ]; then
        exit
      fi

      # kill children if killed, to allow that killing this parent process will end the real fbcli call
      cleanup() {
        echo "aborting fbcli notification (PID $child)"
        pkill -P "$child"
        exit 0  # exit cleanly to avoid swaync alerting a script failure
      }
      trap cleanup SIGINT SIGQUIT SIGTERM

      # feedbackd stops playback when the caller exits
      # and fbcli will exit immediately if it has no stdin.
      # so spoof a stdin:
      /bin/sh -c "true | fbcli $*" &
      child=$!
      wait
    '';
  };
  fbcli = "${fbcli-wrapper}/bin/swaync-fbcli";

  # we do this because swaync's exec naively splits the command on space to produce its argv, rather than parsing the shell.
  # [ "pkill" "-f" "fbcli" "--event" ... ]  -> breaks pkill
  # [ "pkill" "-f" "fbcli --event ..." ]    -> is what we want
  fbcli-stop-wrapper = pkgs.writeShellApplication {
    name = "fbcli-stop";
    runtimeInputs = [
      pkgs.procps  # for pkill
    ];
    text = ''
      pkill -e -f "${fbcli} $*"
    '';
  };
  fbcli-stop = "${fbcli-stop-wrapper}/bin/fbcli-stop";
in
{
  # a script can match regex on these fields. only fired if all listed fields match:
  # - app-name
  # - desktop-entry
  # - summary
  # - body
  # - urgency (Low/Normal/Critical)
  # - category
  # additionally, the script can be run either on receipt or action:
  # - run-on = "receive" or "action"
  # when script is run, these env vars are available:
  # - SWAYNC_BODY
  # - SWAYNC_DESKTOP_ENTRY
  # - SWAYNC_URGENCY
  # - SWAYNC_TIME
  # - SWAYNC_APP_NAME
  # - SWAYNC_CATEGORY
  # - SWAYNC_REPLACES_ID
  # - SWAYNC_ID
  # - SWAYNC_SUMMARY

  # rules to use for testing. trigger with:
  # - `notify-send test test:message` (etc)
  # should also be possible to trigger via any messaging app
  fbcli-test-im = {
    body = "test:message";
    exec = "${fbcli} --event proxied-message-new-instant";
  };
  fbcli-test-call = {
    body = "test:call";
    exec = "${fbcli} --event phone-incoming-call -t 20";
  };
  fbcli-test-call-stop = {
    body = "test:call-stop";
    exec = "${fbcli-stop} --event phone-incoming-call -t 20";
  };

  incoming-im-known-app-name = {
    # trigger notification sound on behalf of these IM clients.
    app-name = "(Chats|Dino|discord|dissent|Element|Fractal)";
    body = "^(?!Incoming call).*$";  #< don't match Dino Incoming calls
    exec = "${fbcli} --event proxied-message-new-instant";
  };
  incoming-im-known-desktop-entry = {
    # trigger notification sound on behalf of these IM clients.
    # these clients don't have an app-name (listed as "<unknown>"), but do have a desktop-entry
    desktop-entry = "com.github.uowuo.abaddon";
    exec = "${fbcli} --event proxied-message-new-instant";
  };
  incoming-call = {
    app-name = "Dino";
    body = "^Incoming call$";
    exec = "${fbcli} --event phone-incoming-call -t 20";
  };
  incoming-call-acted-on = {
    # when the notification is clicked, stop sounding the ringer
    app-name = "Dino";
    body = "^Incoming call$";
    run-on = "action";
    exec = "${fbcli-stop} --event phone-incoming-call -t 20";
  };
}
