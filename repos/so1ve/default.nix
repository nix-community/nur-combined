{
  pkgs ? import <nixpkgs> { },
}:

let
  sources = pkgs.callPackage ./_sources/generated.nix { };
  system = pkgs.stdenv.hostPlatform.system;
in
{
  ab-download-manager = pkgs.callPackage ./pkgs/ab-download-manager {
    source =
      sources."ab-download-manager-${system}"
        or (throw "ab-download-manager: unsupported system ${system}");
  };
  r-maple-mono-nf-cn = pkgs.callPackage ./pkgs/r-maple-mono-nf-cn {
    source = sources.r-maple-mono-nf-cn;
  };

  homeModules = import ./home-modules;
}
