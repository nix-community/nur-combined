# NUR CI entry point: build only free, supported, cacheable packages.
{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) lib;
  nur = import ./default.nix { inherit pkgs; };
  packages = builtins.attrValues (
    builtins.removeAttrs nur [
      "lib"
      "modules"
      "overlays"
    ]
  );
  buildable =
    p:
    lib.isDerivation p
    && lib.meta.availableOn pkgs.stdenv.hostPlatform p
    && !(p.meta.broken or false)
    && builtins.all (license: license.free or true) (lib.toList (p.meta.license or [ ]));
  buildPkgs = builtins.filter buildable packages;
  cachePkgs = builtins.filter (p: !(p.preferLocalBuild or false)) buildPkgs;
  outputsOf = p: map (output: p.${output}) p.outputs;
in
{
  inherit buildPkgs cachePkgs;
  buildOutputs = builtins.concatMap outputsOf buildPkgs;
  cacheOutputs = builtins.concatMap outputsOf cachePkgs;
}
