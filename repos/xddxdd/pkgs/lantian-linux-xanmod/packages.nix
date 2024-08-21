{
  mode ? null,
  callPackage,
  lib,
  linuxKernel,
  sources,
  ...
}:
let
  kernels = callPackage ./default.nix { inherit mode sources; };
in
lib.mapAttrs (_n: v: linuxKernel.packagesFor v) kernels
