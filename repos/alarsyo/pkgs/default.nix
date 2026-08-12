{pkgs}: {
  sddm-sugar-candy = pkgs.callPackage ./sddm-sugar-candy {};
  kaleidoscope-udev-rules = pkgs.callPackage ./kaleidoscope-udev-rules {};
  grafanaDashboards = pkgs.lib.recurseIntoAttrs (pkgs.callPackage ./grafana-dashboards {});
  spot = pkgs.python3Packages.toPythonModule (pkgs.callPackage ./spot {});
}
