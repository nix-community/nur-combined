{ lib }:
lib.mapAttrs (
  source: plugin:
  plugin
  // {
    bundled = plugin.bundled or false;
    packageName =
      if lib.hasPrefix "npm:" source then
        lib.removePrefix "npm:" source
      else if lib.hasPrefix "github:" source then
        plugin.packageName
      else
        throw "Unsupported DSH plugin source: ${source}";
  }
) (builtins.fromJSON (builtins.readFile ./catalog.json))
