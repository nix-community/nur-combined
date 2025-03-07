{ config, pkgs, ... }:
{
  sane.programs."sway-contrib.grimshot" = {
    packageUnwrapped = pkgs.sway-contrib.grimshot.override {
      # my `sway` is heavily patched to be cross compatible
      sway-unwrapped = config.sane.programs.sway.package;
    };
    suggestedPrograms = [
      # runtime dependencies (grimshot is just a trivial shell script)
      "grim"
      "jq"
      "libnotify"  # only if invoked with `-n`
      "slurp"
      # "sway"
      "wl-clipboard"
    ];
    sandbox.keepPids = true;  #< needed by wl-clipboard
    sandbox.whitelistDbus.user = true;  #< TODO: reduce
    sandbox.whitelistWayland = true;
    sandbox.extraRuntimePaths = [
      "sway"
    ];
    sandbox.autodetectCliPaths = "existingFileOrParent";
  };
}
