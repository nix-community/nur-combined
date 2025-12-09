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
lib.mapAttrs (n: v: linuxKernel.packagesFor v) (
  lib.filterAttrs (n: nv: !lib.hasSuffix "configfile" n) kernels
)
