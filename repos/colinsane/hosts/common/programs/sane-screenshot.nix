{ ... }:
{
  sane.programs.sane-screenshot = {
    sandbox.method = "bunpen";
    sandbox.whitelistWayland = true;
    sandbox.whitelistDbus = [ "user" ];  #< to send notifications
    sandbox.extraHomePaths = [
      "Pictures/Screenshots"
    ];
    sandbox.isolatePids = false;  #< it's required (to copy to the clipboard), but unsure why
    sandbox.extraPaths = [ "/proc" ];  #< for nested bwrap invocations
    suggestedPrograms = [
      "libnotify"
      "swappy"
      "sway-contrib.grimshot"
      "util-linux"
      "wl-clipboard"
    ];
  };
}
