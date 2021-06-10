{ pkgs }:
{
  sddm-sugar-candy = pkgs.callPackage ./sddm-sugar-candy {};
  kaleidoscope-udev-rules = pkgs.callPackage ./kaleidoscope-udev-rules {};
}
