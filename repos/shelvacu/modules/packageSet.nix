{
  config,
  pkgs,
  lib,
  vacuModuleType ? "nixos",
  vaculib,
  ...
}:
let
  inherit (lib) mkOption types;
  pkgOptions = builtins.attrValues config.vacu.packages;
  enabledOptions = builtins.filter (o: o.enable) pkgOptions;
  enabledPkgs = builtins.map (o: o.finalPackage) enabledOptions;
  packagesSetType = types.attrsOf (
    types.submodule (
      { name, config, ... }:
      let
        pieces = lib.splitString "." name;
      in
      {
        options = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Will this package be installed (included in environment.systemPackages)";
          };
          package = mkOption {
            type = types.package;
            default = lib.attrByPath pieces (throw "Could not find package pkgs.${name}") pkgs;
            defaultText = "pkgs.${name}";
          };
          overrides = mkOption {
            type = types.nullOr (types.attrsOf types.anything);
            default = null;
          };
          finalPackage = mkOption {
            type = types.package;
            readOnly = true;
          };
        };
        config.finalPackage =
          if config.overrides == null then config.package else config.package.override config.overrides;
      }
    )
  );
  enable = lib.mkOverride 900 true; # more important than mkDefault, less important than setting explicitly
  nameToPackageSet = name: {
    inherit name;
    value = { inherit enable; };
  };
  listToPackageSet = vaculib.mapListToAttrs (
    val:
    if builtins.isString val then
      nameToPackageSet val
    else
      assert lib.isDerivation val;
      {
        name = val.pname or val.name;
        value = {
          inherit enable;
          package = lib.mkDefault val;
        };
      }
  );
  stringToPackageSet =
    from:
    lib.pipe from [
      (vaculib.listOfLines { })
      (vaculib.mapListToAttrs nameToPackageSet)
    ];
  listOrStringToPackageSet =
    from:
    if builtins.isString from then
      stringToPackageSet from
    else if builtins.isList from then
      listToPackageSet from
    else
      throw "this should never happen; should be a list or string";
  listTy = types.listOf (types.either types.str types.package);
in
{
  imports =
    [ ]
    ++ lib.optional (vacuModuleType == "nixos") {
      environment.systemPackages = config.vacu.finalPackageList;
    }
    ++ lib.optional (vacuModuleType == "nix-on-droid") {
      environment.packages = config.vacu.finalPackageList;
    };
  options = {
    vacu.packages = mkOption {
      default = { };
      type = types.coercedTo (types.either listTy types.str) listOrStringToPackageSet packagesSetType;
    };
    vacu.finalPackageList = mkOption {
      type = types.listOf types.package;
      readOnly = true;
    };
  };

  config.vacu.finalPackageList = enabledPkgs;
}
