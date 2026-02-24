{
  pkgs,
  lib ? pkgs.lib,
}:

let
  self = import ../. { inherit pkgs; };
in
rec {

  allImporters = lib.pipe self.lib [
    (
      it:
      (lib.filterAttrs (
        name: value: (lib.hasPrefix "import" name) && name != "import" && value ? check
      ) it)
    )
    lib.attrValues
  ];

  findImporter =
    file:
    lib.findFirst
      # Predicate
      (el: el.check file)
      # Default value
      builtins.import
      # List to search
      allImporters;

  import = file: (findImporter file) file;

}
