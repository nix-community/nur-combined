{ ... }:
{
  sane.programs.sane-screenshot = {
    sandbox.whitelistWayland = true;
    sandbox.whitelistDbus = [ "user" ];  #< to send notifications
    sandbox.extraHomePaths = [
      "Pictures/Screenshots"
    ];
    sandbox.keepPidsAndProc = true;  #< it's required (to copy to the clipboard), but unsure why
    suggestedPrograms = [
      "libnotify"
      "swappy"
      "sway-contrib.grimshot"
      "util-linux"
      "wl-clipboard"
    ];
  };
}
