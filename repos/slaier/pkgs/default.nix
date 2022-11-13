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
  material-fox = callPackage ./material-fox { };
  arkenfox-userjs = callPackage ./arkenfox-userjs { };
  clash-speedtest = callPackage ./clash-speedtest { };
  vscode-extensions = recurseIntoAttrs (mapAttrs (_n: recurseIntoAttrs) (callPackages ./vscode-extensions { }));
}
