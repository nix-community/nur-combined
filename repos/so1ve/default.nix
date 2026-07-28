{
  pkgs ? import <nixpkgs> { },
}:

let
  sources = pkgs.callPackage ./_sources/generated.nix { };
in
{
  ab-download-manager = pkgs.callPackage ./pkgs/ab-download-manager { };
  r-maple-mono-nf-cn = pkgs.callPackage ./pkgs/r-maple-mono-nf-cn {
    source = sources.r-maple-mono-nf-cn;
  };
  radmin-vpn = pkgs.callPackage ./pkgs/radmin-vpn { };

  homeModules = import ./home-modules;
}
