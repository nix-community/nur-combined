{ lib, self, ... }:
{
  perSystem =
    {
      final,
      ...
    }:
    let
      templates = "${self}/templates";
      filterDirectories = builtins.filter ({ value, ... }: value == "directory");
      evaluatePackages = builtins.map (
        { name, ... }:
        {
          "${name}" = final.callPackage "${templates}/${name}/default.nix" { };
        }
      );
    in
    {
      checks = lib.pipe templates [
        builtins.readDir
        lib.attrsToList
        filterDirectories
        evaluatePackages
        lib.mergeAttrsList
      ];
    };
}
