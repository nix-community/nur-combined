let
  packages = [
    "safebucket"
    "rustic-exporter"
  ];
in
{
  default = _final: prev: prev.lib.genAttrs packages (name: prev.callPackage ../pkgs/${name} { });
}
