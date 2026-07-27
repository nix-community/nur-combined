{
  pkgs ? import <nixpkgs> { },
}:

let
  inherit (builtins)
    attrNames
    attrValues
    concatLists
    filter
    isAttrs
    listToAttrs
    map
    ;

  reservedNames = [
    "darwinModules"
    "flakeModules"
    "homeModules"
    "lib"
    "nixosModules"
    "overlays"
  ];

  isDerivation = value: isAttrs value && value ? type && value.type == "derivation";
  isBuildable =
    package:
    let
      licenses =
        if builtins.isList (package.meta.license or [ ]) then
          package.meta.license or [ ]
        else
          [ package.meta.license ];
    in
    !(package.meta.broken or false) && builtins.all (license: license.free or true) licenses;
  isCacheable = package: !(package.preferLocalBuild or false);
  shouldRecurse = value: isAttrs value && value.recurseForDerivations or false;

  flatten =
    values:
    concatLists (
      map (
        value:
        if shouldRecurse value then
          flatten (attrValues value)
        else if isDerivation value then
          [ value ]
        else
          [ ]
      ) values
    );

  repository = import ./default.nix { inherit pkgs; };
  packageNames = filter (name: !(builtins.elem name reservedNames)) (attrNames repository);
  packages = flatten (
    attrValues (
      listToAttrs (
        map (name: {
          inherit name;
          value = repository.${name};
        }) packageNames
      )
    )
  );
in
rec {
  buildPkgs = filter isBuildable packages;
  cachePkgs = filter (package: isBuildable package && isCacheable package) packages;

  buildOutputs = concatLists (
    map (package: map (output: package.${output}) package.outputs) buildPkgs
  );
  cacheOutputs = concatLists (
    map (package: map (output: package.${output}) package.outputs) cachePkgs
  );
}
