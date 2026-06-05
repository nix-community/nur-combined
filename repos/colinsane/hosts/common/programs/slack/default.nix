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
{ lib, pkgs, ... }:
{
  sane.programs.slack = {
    packageUnwrapped = pkgs.slack.overrideAttrs (prevAttrs: {
      # fix to use wayland instead of Xwayland:
      # - replace `NIXOS_OZONE_WL` non-empty check with `WAYLAND_DISPLAY`
      # - use `wayland` instead of `auto` because --ozone-platform-hint=auto still prefers X over wayland when both are available
      # alternatively, set env var: `ELECTRON_OZONE_PLATFORM_HINT=wayland` and ignore all of this
      installPhase = lib.replaceStrings
        [ "NIXOS_OZONE_WL" "--ozone-platform-hint=auto" ]
        [ "WAYLAND_DISPLAY" "--ozone-platform-hint=wayland" ]
        prevAttrs.installPhase
      ;

      # disable Ctrl+W = Close shortcut
      postInstall = (prevAttrs.postInstall or "") + ''
        asar extract $out/lib/slack/resources/app.asar app.tmp
        substituteInPlace app.tmp/dist/main.bundle.cjs \
          --replace-fail '{...this.buildCloseMenuItem(),order:60},' ""
        asar pack app.tmp $out/lib/slack/resources/app.asar
      '';
      # other ways to disable Ctrl+W, with mixed results
      # --replace-fail 'this.buildCloseMenuItem()' 'this.buildQuitMenuItem()'
      # --replace-fail ',accelerator:"CmdOrCtrl+W"' ""
      # --replace-fail 'buildCloseMenuItem(){' 'buildCloseMenuItem(){return;'
      # --replace-fail '(()=>{' '(()=>{const { app, globalShortcut, Menu } = require("electron"); app.on("ready", () => { Menu.setApplicationMenu(null); }); '
    });
    suggestedPrograms = [
      # "xdg-mime"
      "xdg-open"
      # "xdg-email"
      # "xdg-settings"
    ];

    # sandbox.whitelistDbus.user = true;
    sandbox.net = "clearnet";
    sandbox.whitelistAudio = true;  #< for calls, media
    sandbox.whitelistAvDev = true;  #< for webcam access
    sandbox.whitelistDri = true;
    sandbox.whitelistPortal = [
      "Camera"  # not sure if used
      "DynamicLauncher"  #< used to launch file browser when viewing downloads
      "FileChooser"  #< seems to not actually be used though
      "OpenURI"
      "ScreenCast"  # not sure if used
    ];
    sandbox.extraHomePaths = [
      "tmp"
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

