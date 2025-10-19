self: super:
with super.lib;
let
  luaNames = [
    (nameAndPkgs "lua" "luaPackages")
    (nameAndPkgs "lua5_1" "lua51Packages")
    (nameAndPkgs "lua5_2" "lua52Packages")
    (nameAndPkgs "lua5_3" "lua53Packages")
    (nameAndPkgs "lua5_4" "lua54Packages")
    (nameAndPkgs "luajit" "luajitPackages")
  ];
  nameAndPkgs = name: pkgs: {
    interpreter = name;
    packages = pkgs;
  };

  overriddenLuas = concatMap overriddenLua luaNames;
  overriddenLua =
    { interpreter, packages }:
    let
      packageOverrides = composeManyExtensions self.lib.luaOverrides;
      newLua = super.${interpreter}.override { inherit packageOverrides; };
    in
    [
      {
        name = interpreter;
        value = newLua;
      }
      {
        name = packages;
        value = newLua.pkgs;
      }
    ];
in
{
  lib = (super.lib or { }) // {
    # We use this by specifying overrides in the below, they get fed down into all luaPackages
    luaOverrides = [ ];
    defineLuaPackageOverrides = super: overrides: {
      lib = super.lib // {
        luaOverrides = super.lib.luaOverrides ++ overrides;
      };
    };
  };
}
// builtins.listToAttrs overriddenLuas
