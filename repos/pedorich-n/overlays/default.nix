let
  packages = [
    "error-pages"
    "rustic-exporter"
    "safebucket"
  ];
in
{
  default = _final: prev: prev.lib.genAttrs packages (name: prev.callPackage ../pkgs/${name} { });
}
