# this file defines the `scripts` entry within ~/.config/swaync/config.json.
# it describes special things to do in response to specific notifications,
# e.g. sound a ringer when we get a call, ...
{ pkgs }:
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
  # - `notify-send --app-id=foo subject body` (etc)
  # should also be possible to trigger via any messaging app
  fbcli-test-im = {
    body = "test:message";
    exec = "swaync-fbcli start proxied-message-new-instant";
  };
  fbcli-test-call = {
    body = "test:call-start";
    exec = "swaync-fbcli start phone-incoming-call";
  };
  fbcli-test-call-stop = {
    body = "test:call-stop";
    exec = "swaync-fbcli stop phone-incoming-call";
  };

  incoming-im-known-app-name = {
    # trigger notification sound on behalf of these IM clients.
    app-name = "(Chats|Dino|discord|dissent|Element|Fractal)";
    body = "^(?!Incoming call).*$";  #< don't match Dino Incoming calls
    exec = "swaync-fbcli start proxied-message-new-instant";
  };
  incoming-im-known-desktop-entry = {
    # trigger notification sound on behalf of these IM clients.
    # these clients don't have an app-name (listed as "<unknown>"), but do have a desktop-entry
    desktop-entry = "com.github.uowuo.abaddon";
    exec = "swaync-fbcli start proxied-message-new-instant";
  };
  incoming-call = {
    app-name = "Dino";
    body = "^Incoming call$";
    exec = "swaync-fbcli start phone-incoming-call";
  };
  incoming-call-acted-on = {
    # when the notification is clicked, stop sounding the ringer
    app-name = "Dino";
    body = "^Incoming call$";
    run-on = "action";
    exec = "swaync-fbcli stop phone-incoming-call";
  };
}
