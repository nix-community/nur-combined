{ ... }:
{
  sane.programs.sane-open = {
    sandbox.method = "bunpen";
    sandbox.autodetectCliPaths = "existing";  # for when opening a file
    sandbox.whitelistDbus = [ "user" ];
    sandbox.isolatePids = false;  #< to toggle keyboard
    sandbox.extraHomePaths = [
      ".local/share/applications"
    ];
    sandbox.extraRuntimePaths = [ "sway" ];  #< calls `swaymsg` to query rotation and see if there's room for a keyboard
    sandbox.extraPaths = [ "/proc" ];  #< to be able to launch bwrap programs
    suggestedPrograms = [
      "gdbus"
      "xdg-utils"
    ];

    mime.associations."application/x-desktop" = "sane-open-desktop.desktop";
  };
}
