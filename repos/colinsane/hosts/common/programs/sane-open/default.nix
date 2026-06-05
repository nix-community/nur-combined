{ config, ... }:
{
  sane.programs.sane-open = {
    suggestedPrograms = [
      "gdbus"
      "mimeo-query-desktop"
    ];

    sandbox.autodetectCliPaths = "existing";  # for when opening a file
    sandbox.extraHomePaths = config.sane.programs.mimeo-query-desktop.sandbox.extraHomePaths;
    sandbox.extraRuntimePaths = [ "sway" ];  #< calls `swaymsg` to query rotation and see if there's room for a keyboard
    sandbox.keepPidsAndProc = true;  #< to toggle keyboard
    sandbox.whitelistPortal = [
      "DynamicLauncher"
      "OpenURI"
    ];

    mime.associations."application/x-desktop" = "sane-open-desktop.desktop";
  };

  sane.programs."sane-open.clipboard" = {
    suggestedPrograms = [
      "sane-open"
      "wl-clipboard-rs"
    ];

    # this calls into `sane-open`, but explicitly doesn't use all functionality,
    # so doesn't need all sandboxing.
    # that might hint that the packages should be split/restructured...
    sandbox.whitelistWayland = true;  #< to access clipboard
    sandbox.whitelistPortal = [
      "OpenURI"
    ];
  };
}
