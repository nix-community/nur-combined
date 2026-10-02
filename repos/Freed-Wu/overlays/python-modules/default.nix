# Inject the python-modules of this repo into every CPython interpreter's
# package set, so they are available as e.g. python313Packages.pyrime and can
# be used with python3.withPackages for any python version.
final: prev:
let
  lib = prev.lib;
  moduleDir = ../../pkgs/development/python-modules;
  moduleNames = builtins.filter (
    name: lib.pathIsDirectory (moduleDir + "/${name}")
  ) (builtins.attrNames (builtins.readDir moduleDir));
  mySources = prev.callPackage ../../_sources/generated.nix { };
  packageSetFn =
    pySelf: pySuper:
    let
      modules = lib.genAttrs moduleNames (
        name:
        let
          f = import (moduleDir + "/${name}");
          scope = prev // {
            inherit mySources;
            python3 = pySelf.python;
          } // modules;
        in
        f (builtins.intersectAttrs (builtins.functionArgs f) scope)
      );
    in
    modules;
  isInterpreter = name: name == "python3" || builtins.match "^python3[0-9]+$" name != null;
in
builtins.listToAttrs (
  map (
    name: {
      inherit name;
      value = prev.${name}.override { packageOverrides = packageSetFn; };
    }
  ) (builtins.filter isInterpreter (builtins.attrNames prev))
)
