let
  flake = builtins.getFlake (toString ./..);
  pkgs = flake.inputs.nixpkgs.legacyPackages.x86_64-linux;
  inherit (pkgs) lib;

  reservedAttrs = [
    "darwinModules"
    "flakeModules"
    "homeModules"
    "lib"
    "nixosModules"
    "overlays"
  ];

  licenseName =
    license:
    if builtins.isString license then
      license
    else
      license.spdxId or license.shortName or license.fullName or null;

  packageMetadata =
    attrPath: package:
    let
      license = package.meta.license or null;
    in
    {
      attr = lib.concatStringsSep "." attrPath;
      description = package.meta.description or null;
      hidden = package.passthru.hideFromDocs or false;
      homepage = package.meta.homepage or null;
      license =
        if license == null then
          null
        else if builtins.isList license then
          map licenseName license
        else
          [ (licenseName license) ];
      name = package.name or null;
      version = package.version or null;
    };

  collect =
    attrPath: value:
    if lib.isDerivation value then
      [ (packageMetadata attrPath value) ]
    else if builtins.isAttrs value && (value.recurseForDerivations or false) then
      lib.concatLists (lib.mapAttrsToList (name: child: collect (attrPath ++ [ name ]) child) value)
    else
      [ ];

  packageSet = import ../default.nix { inherit pkgs; };
in
lib.concatLists (
  lib.mapAttrsToList (
    name: value: if builtins.elem name reservedAttrs then [ ] else collect [ name ] value
  ) packageSet
)
