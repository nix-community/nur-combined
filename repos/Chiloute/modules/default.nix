# NixOS modules imported from the tagged upstream source: no copy kept in this repo.
# `imports` cannot depend on the module system's `pkgs`, and NUR evaluates this file with
# pkgs = throw: the pin is read from the package file with stub fetchers and fetched with builtins.
let
  pin =
    (import ../pkgs/vpn-tui {
      lib = null;
      callPackage = null;
      symlinkJoin = args: args;
      fetchFromGitHub = args: args;
    }).passthru.src;
  vpnTuiSrc = builtins.fetchTarball {
    url = "https://github.com/${pin.owner}/${pin.repo}/archive/${pin.rev}.tar.gz";
    sha256 = pin.hash;
  };
in {
  vpn-tui = {
    lib,
    pkgs,
    ...
  }: {
    imports = ["${vpnTuiSrc}/nix/module.nix"];
    services.vpn-tui.package = lib.mkDefault (pkgs.callPackage ../pkgs/vpn-tui {});
  };
}
