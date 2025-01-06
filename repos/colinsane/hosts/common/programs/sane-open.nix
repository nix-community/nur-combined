{ ... }:
{
  sane.programs.sane-open = {
    suggestedPrograms = [
      "gdbus"
      "xdg-utils"
    ];

    sandbox.autodetectCliPaths = "existing";  # for when opening a file
    sandbox.whitelistDbus.user = true;  #< TODO: reduce
    sandbox.keepPidsAndProc = true;  #< to toggle keyboard
    sandbox.extraHomePaths = [
      ".local/share/applications"
    ];
    sandbox.extraRuntimePaths = [ "sway" ];  #< calls `swaymsg` to query rotation and see if there's room for a keyboard

    mime.associations."application/x-desktop" = "sane-open-desktop.desktop";
  };

  sane.programs."sane-open.clipboard" = {
    suggestedPrograms = [
      "sane-open"
    ];

    # this calls into `sane-open`, but explicitly doesn't use all functionality,
    # so doesn't need all sandboxing.
    # that might hint that the packages should be split/restructured...
    sandbox.whitelistWayland = true;  #< to access clipboard
    sandbox.whitelistDbus.user = true;  #< TODO: reduce
  };
}
