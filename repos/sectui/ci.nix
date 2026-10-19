# What CI builds. From nix-community/nur-packages-template.
{pkgs ? import <nixpkgs> {}}:
with builtins; let
  isReserved = n: n == "lib" || n == "overlays" || n == "nixosModules" || n == "homeModules" || n == "darwinModules" || n == "flakeModules";
  isDerivation = p: isAttrs p && p ? type && p.type == "derivation";
  isBuildable = p: let
    licenseFromMeta = p.meta.license or [];
    licenseList =
      if isList licenseFromMeta
      then licenseFromMeta
      else [licenseFromMeta];
  in
    !(p.meta.broken or false) && all (license: license.free or true) licenseList;
  isCacheable = p: !(p.preferLocalBuild or false);
  shouldRecurseForDerivations = p: isAttrs p && p.recurseForDerivations or false;

  flattenPkgs = s:
    concatMap (p:
      if shouldRecurseForDerivations p
      then flattenPkgs p
      else if isDerivation p
      then [p]
      else []) (attrValues s);

  outputsOf = p: map (o: p.${o}) p.outputs;

  nurAttrs = import ./default.nix {inherit pkgs;};

  nurPkgs = flattenPkgs (removeAttrs nurAttrs (filter isReserved (attrNames nurAttrs)));
in rec {
  buildPkgs = filter isBuildable nurPkgs;
  cachePkgs = filter isCacheable buildPkgs;

  buildOutputs = concatMap outputsOf buildPkgs;
  cacheOutputs = concatMap outputsOf cachePkgs;
}
