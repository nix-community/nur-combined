{ pkgs, ... }:
let
  inherit (pkgs.lib) callPackageWith callPackagesWith recurseIntoAttrs mapAttrs;
  autoArgs = pkgs // {
    sources = pkgs.callPackage ./_sources/generated.nix { };
  };
  callPackage = callPackageWith autoArgs;
  callPackages = callPackagesWith autoArgs;
in
{
  arkenfox-userjs = callPackage ./arkenfox-userjs { };
  clash-geoip = callPackage ./clash-geoip { };
  firefox-addons = recurseIntoAttrs (callPackages ./firefox-addons { });
  material-fox = callPackage ./material-fox { };
  motrix = callPackage ./motrix { };
  programs-db = callPackage ./programs-db { };
  ubootPhicommN1 = callPackage ./uboot-phicomm-n1 { };
  vscode-extensions = recurseIntoAttrs (mapAttrs (_n: recurseIntoAttrs) (callPackages ./vscode-extensions { }));
  yacd = callPackage ./yacd { };
}
