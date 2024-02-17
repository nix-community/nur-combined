{ pkgs }:

pkgs.lib.makeScope pkgs.newScope (self:
let
  # Convert a string to a path.  builtins.toPath is deprecated and recommends this
  toPath = s: ./. + "/${s}";
  # All subdirectories contain packages
  directories = builtins.attrNames
    (pkgs.lib.attrsets.filterAttrs
      (_: v: v == "directory")
      (builtins.readDir ./.)
    );
  pkg_list = builtins.map
    (dir: {
      name = dir;
      value = self.callPackage (toPath dir) { };
    })
    directories;
in
builtins.listToAttrs pkg_list
)
