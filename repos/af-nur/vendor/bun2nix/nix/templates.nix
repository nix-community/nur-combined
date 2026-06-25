{ lib, self, ... }:
let
  templates = "${self}/templates";
  filterDirectories = builtins.filter ({ value, ... }: value == "directory");
  toTemplates = builtins.map (
    { name, ... }:
    {
      "${name}" = {
        path = "${templates}/${name}";
        description = "${name}";
      };
    }
  );
in
{
  flake.templates = lib.pipe templates [
    builtins.readDir
    lib.attrsToList
    filterDirectories
    toTemplates
    lib.mergeAttrsList
  ];
}
