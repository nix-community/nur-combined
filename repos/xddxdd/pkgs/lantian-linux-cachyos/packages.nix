{
  callPackage,
  lib,
  linuxKernel,
  ...
}:
let
  kernels = callPackage ./default.nix { };
in
lib.mapAttrs (
  n: v:
  let
    packages = linuxKernel.packagesFor v;
  in
  packages
  // lib.mapAttrs (
    _: m:
    if lib.isDerivation m && !(m.__structuredAttrs or false) then
      m.overrideAttrs (_: {
        __structuredAttrs = true;
        strictDeps = true;
      })
    else
      m
  ) packages
) kernels
