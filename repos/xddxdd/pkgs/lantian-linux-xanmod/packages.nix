{
  callPackage,
  lib,
  linuxKernel,
  sources,
  ...
}:
let
  kernels = callPackage ./default.nix { inherit sources; };
in
lib.mapAttrs (_n: v: linuxKernel.packagesFor v) kernels
