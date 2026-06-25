{ pkgs, bun2nix ? pkgs.callPackage ./bun2nix-shim { }, ... }:
{
  classin = pkgs.callPackage ./classin { };
  hhsh = pkgs.callPackage ./hhsh { };
  linuxqq-clipsync = pkgs.callPackage ./linuxqq-clipsync { };
  mefrpc = pkgs.callPackage ./mefrpc { };
  xwaylandvideobridge = pkgs.callPackage ./xwaylandvideobridge { };
  rikkahub-desktop = pkgs.callPackage ./rikkahub-desktop { inherit bun2nix; };
  rikkahub-desktop-bin = pkgs.callPackage ./rikkahub-desktop-bin { };
}
