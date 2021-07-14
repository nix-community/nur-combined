{ pkgs }:
{
  sddm-sugar-candy = pkgs.callPackage ./sddm-sugar-candy {};
  kaleidoscope-udev-rules = pkgs.callPackage ./kaleidoscope-udev-rules {};
  grafanaDashboards = pkgs.recurseIntoAttrs (pkgs.callPackage ./grafana-dashboards {});
  spot = pkgs.callPackage ./spot {};
}
