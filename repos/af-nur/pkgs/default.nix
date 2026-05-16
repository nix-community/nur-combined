{ pkgs }:
{
  classin = pkgs.callPackage ./classin { };
  mefrpc = pkgs.callPackage ./mefrpc { };
  xwaylandvideobridge = pkgs.callPackage ./xwaylandvideobridge { };
}
