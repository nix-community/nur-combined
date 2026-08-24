{
  callPackage,
  lib,
  linuxKernel,
  ...
}:
let
  kernels = callPackage ./default.nix { };
in
lib.mapAttrs (n: v: linuxKernel.packagesFor v) kernels
