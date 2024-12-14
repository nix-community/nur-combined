{ ... }:
{
  sane.programs.sane-screenshot = {
    sandbox.whitelistDbus = [ "user" ];  #< to send notifications
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      "Pictures/Screenshots"
    ];
    sandbox.extraRuntimePaths = [
      "sway"
    ];
    sandbox.keepPidsAndProc = true;  #< it's required (to copy to the clipboard), but unsure why
    suggestedPrograms = [
      "grim"
      "jq"
      "libnotify"
      "slurp"
      "swappy"
      # "sway-contrib.grimshot"
      "util-linux"
      "wl-clipboard"
    ];
  };
}
