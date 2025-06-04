# auth flow:
# - launch Slack
# - click the login button
#   -> slack opens https://... to the slack.com login, via portal
# - in browser, follow the auth prompts
#   -> may involve *several* pages of SSO, and email one-time tokens.
#   -> browser will try to launch a `slack://...` URI, to communicate the auth back to the desktop
#   -> xdg-desktop-portal receives the slack:// request, launches a _new_ slack instance.
#   -> presumably: new slack instance locates ~/.config/Slack/SingletonSocket;
#      forwards the auth details to existing application
#
{ ... }:
{
  sane.programs.slack = {
    # sandbox.whitelistDbus.user = true;
    sandbox.net = "clearnet";
    sandbox.whitelistAudio = true;  #< for calls, media
    sandbox.whitelistAvDev = true;  #< for webcam access
    sandbox.whitelistDri = true;
    sandbox.whitelistPortal = [
      "Camera"  # not sure if used
      "FileChooser"  #< seems to not actually be used though
      "OpenURI"
      "ScreenCast"  # not sure if used
    ];
    sandbox.whitelistSendNotifications = true;
    sandbox.whitelistWayland = true;
    # mime.urlAssociations."^slack://.*$" = "slack.desktop";
    mime.associations."x-scheme-handler/slack" = "slack.desktop";  #< required as part of auth flow
    persist.byStore.private = [
      # ~/.config/Slack contains everything:
      # - Cookies
      # - Preferences
      # - SingletonSocket
      #   - presumably used for IPC, so that `slack slack://...` can forward to the existing instance
      # - caches/storage
      # TODO: don't persist this entire directory
      ".config/Slack"
    ];
    sandbox.tmpDir = ".config/Slack/tmp";  #< tmpdir needs to be shared between instances, for the singleton socket to work
  };
}

