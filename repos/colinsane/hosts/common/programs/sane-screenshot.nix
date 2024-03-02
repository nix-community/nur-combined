{ ... }:
{
  sane.programs.sane-screenshot = {
    sandbox.method = "bwrap";
    sandbox.whitelistWayland = true;
    sandbox.whitelistDbus = [ "user" ];  #< to send notifications
    sandbox.extraHomePaths = [
      "Pictures/Screenshots"
    ];
    suggestedPrograms = [
      "libnotify"
      "swappy"
      "sway-contrib.grimshot"
      "util-linux"
      "wl-clipboard"
    ];
  };
}
