# Inject the lua-modules of this repo into every Lua interpreter's package
# set, so they are available as e.g. lua54Packages.prompt-style and through
# lua5_1.withPackages for any lua version.
final: prev:
let
  lib = prev.lib;
  moduleDir = ../../pkgs/development/lua-modules;
  moduleNames = builtins.filter (
    name: lib.pathIsDirectory (moduleDir + "/${name}")
  ) (builtins.attrNames (builtins.readDir moduleDir));
  packageSetFn =
    self: super:
    let
      modules = lib.genAttrs moduleNames (
        name:
        let
          f = import (moduleDir + "/${name}");
          scope = prev // self // modules;
        in
        f (builtins.intersectAttrs (builtins.functionArgs f) scope)
      );
    in
    modules;
  isInterpreter =
    name:
    name == "lua"
    || name == "luajit"
    || name == "luajit52"
    || builtins.match "^lua5_[0-9]+$" name != null;
in
builtins.listToAttrs (
  map (
    name: {
      inherit name;
      value = prev.${name}.override { packageOverrides = packageSetFn; };
    }
  ) (builtins.filter isInterpreter (builtins.attrNames prev))
)
