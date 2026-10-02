# Inject the tcl-modules of this repo into every Tcl package set, so they are
# available as e.g. tclPackages.tcl-prompt (and tcl9Packages.* for Tcl 9).
# Packages follow nixpkgs' by-name layout:
# pkgs/development/tcl-modules/by-name/<first two letters>/<pname>/package.nix
final: prev:
let
  lib = prev.lib;
  byNameRoot = ../../pkgs/development/tcl-modules/by-name;
  subDirs =
    path:
    builtins.filter (
      name: (builtins.readDir path).${name} == "directory"
    ) (builtins.attrNames (builtins.readDir path));
  packagePaths = lib.concatMap (
    prefix:
    map (
      name:
      byNameRoot + "/${prefix}/${name}/package.nix"
    ) (subDirs (byNameRoot + "/${prefix}"))
  ) (subDirs byNameRoot);
  packageSetFn =
    self: super:
    let
      modules = builtins.listToAttrs (
        map (
          path: {
            name = baseNameOf (dirOf path);
            value =
              let
                f = import path;
                scope = prev // self // modules // {
                  tclPackages = self;
                };
              in
              f (builtins.intersectAttrs (builtins.functionArgs f) scope);
          }
        ) packagePaths
      );
    in
    modules;
  isPackageSet = name: builtins.match "^tcl[0-9]+Packages$" name != null;
in
builtins.listToAttrs (
  map (
    name: {
      inherit name;
      value = prev.${name}.overrideScope packageSetFn;
    }
  ) (builtins.filter isPackageSet (builtins.attrNames prev))
)
