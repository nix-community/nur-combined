{ pkgs, bun2nix ? null, ... }:
{
  classin = pkgs.callPackage ./classin { };
  hhsh = pkgs.callPackage ./hhsh { };
  linuxqq-clipsync = pkgs.callPackage ./linuxqq-clipsync { };
  mefrpc = pkgs.callPackage ./mefrpc { };
  xwaylandvideobridge = pkgs.callPackage ./xwaylandvideobridge { };
} // pkgs.lib.optionalAttrs (bun2nix != null) {
  rikkahub-desktop = pkgs.callPackage ./rikkahub-desktop { inherit bun2nix; };
}
