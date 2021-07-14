{ pkgs }:
{
  sddm-sugar-candy = pkgs.callPackage ./sddm-sugar-candy {};
  kaleidoscope-udev-rules = pkgs.callPackage ./kaleidoscope-udev-rules {};
  grafana-dashboards = pkgs.callPackage ./grafana-dashboards {};
  spot = pkgs.callPackage ./spot {};
}
