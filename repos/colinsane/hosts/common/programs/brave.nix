{ pkgs, ... }:
{
  sane.programs.brave = {
    # convert eval error to build failure
    packageUnwrapped = if (builtins.tryEval pkgs.brave).success then
      pkgs.brave.overrideAttrs (upstream: {
        # brave does crimes with `$0` which break under transparent wrapping
        preFixup = (upstream.preFixup or "") + ''
          substituteInPlace $out/opt/brave.com/brave/brave-browser \
            --replace '$0' "$out/opt/brave.com/brave/brave-browser"
        '';
      })
    else
      pkgs.runCommandLocal "brave-not-supported" {} "false"
    ;
    sandbox.wrapperType = "inplace";  #< package contains dangling symlinks which my wrapper doesn't understand
    sandbox.net = "all";
    sandbox.extraHomePaths = [
      "dev"  # for developing anything web-related
      "tmp"
    ];
    sandbox.extraPaths = [
      "/tmp"  # needed particularly if run from `sane-vpn do`
    ];
    sandbox.mesaCacheDir = ".cache/BraveSoftware/mesa";
    sandbox.whitelistAudio = true;
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;

    persist.byStore.ephemeral = [
      ".cache/BraveSoftware"
      ".config/BraveSoftware"
    ];
  };
}
