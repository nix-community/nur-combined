# BUGS
# - switchboard-plug-sound errors because
#   GLib-GIO-ERROR **: Settings schema 'org.gnome.settings-daemon.plugins.media-keys' is not installed
{ pkgs, ... }:
{
  sane.programs.switchboard = {
    packageUnwrapped = with pkgs.pantheon; switchboard-with-plugs.override {
      switchboardPlugs = [
        # switchboard-plug-a11y
        # switchboard-plug-about
        # switchboard-plug-applications
        # switchboard-plug-bluetooth  #< TODO(2024/06/13): would be nice to have, but doesn't cross-compile
        # switchboard-plug-datetime
        # switchboard-plug-display  # could be handy, but crashes
        # switchboard-plug-keyboard
        # switchboard-plug-mouse-touchpad  # changing settings here doesn't actually impact anything real
        switchboard-plug-network
        # switchboard-plug-notifications
        # switchboard-plug-onlineaccounts
        # switchboard-plug-pantheon-shell
        # switchboard-plug-power  # needs to be "unlocked" before it can do anything (like change display brightness)
        # switchboard-plug-printers  # requires cups
        # switchboard-plug-security-privacy
        # switchboard-plug-sharing
        switchboard-plug-sound
        # switchboard-plug-wacom
      ];
      xorg = pkgs.buildPackages.xorg;  #< cross compilation fix (TODO: upstream)
    };
    sandbox.whitelistWayland = true;
    sandbox.whitelistDbus = [ "system" ];  #< to speak with NetworkManager
    sandbox.whitelistAudio = true;  #< even with this, the sound plugin doesn't seem to work...
    sandbox.mesaCacheDir = ".cache/switchboard/mesa";  # TODO: is this the correct app-id?
  };
}
