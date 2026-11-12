# NixOS modules imported from the tagged upstream source: no copy kept in this repo.
# `imports` cannot depend on the module system's `pkgs`, hence the source passed in here.
{vpnTuiSrc}: {
  vpn-tui = {
    lib,
    pkgs,
    ...
  }: let
    upstream = import "${vpnTuiSrc}/nix/module.nix";
    package = pkgs.callPackage ../pkgs/vpn-tui {};
  in {
    # shortcut: v0.1.0's module takes the flake `self`; a plain module (named args) is used as is.
    # Remove the `self` branch once every supported tag ships the plain module.
    imports = [
      (
        if builtins.functionArgs upstream == {}
        then upstream {packages.${pkgs.stdenv.hostPlatform.system}.default = package;}
        else upstream
      )
    ];
    services.vpn-tui.package = lib.mkDefault package;
  };
}
