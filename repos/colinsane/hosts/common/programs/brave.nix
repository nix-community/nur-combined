{ pkgs, ... }:
{
  sane.programs.brave = {
    # convert eval error to build failure
    packageUnwrapped = if (builtins.tryEval pkgs.brave).success then
      pkgs.brave
    else
      pkgs.runCommandLocal "brave-not-supported" {} "false"
    ;
    sandbox.method = "bwrap";
    sandbox.wrapperType = "inplace";  # /opt/share/brave.com vendor-style packaging
    sandbox.net = "all";
    sandbox.extraHomePaths = [
      "dev"  # for developing anything web-related
      "tmp"
    ];
    sandbox.extraPaths = [
      "/tmp"  # needed particularly if run from `sane-vpn do`
    ];
    sandbox.whitelistAudio = true;
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;

    persist.byStore.cryptClearOnBoot = [
      ".cache/BraveSoftware"
      ".config/BraveSoftware"
    ];
  };
}
