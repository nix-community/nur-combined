{
  pkgs ? import <nixpkgs> { },
}:

let
  sources = pkgs.callPackage ./_sources/generated.nix { };
in
{
  ab-download-manager = pkgs.callPackage ./pkgs/ab-download-manager { };
  fcitx5-mellow-themes = pkgs.callPackage ./pkgs/fcitx5-mellow-themes { };
  firefoxpwa-xwayland = pkgs.callPackage ./pkgs/firefoxpwa-xwayland { };
  r-maple-mono-nf-cn = pkgs.callPackage ./pkgs/r-maple-mono-nf-cn {
    source = sources.r-maple-mono-nf-cn;
  };
  yanhekt-autoslides = pkgs.callPackage ./pkgs/yanhekt-autoslides {
    source = sources.yanhekt-autoslides;
  };
  winboat-unstable = pkgs.callPackage ./pkgs/winboat-unstable {
    source = sources.winboat;
  };

  homeModules = import ./home-modules;
}
