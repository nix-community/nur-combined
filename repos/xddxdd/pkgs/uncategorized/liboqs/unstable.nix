{ sources, callPackage, ... }:
(callPackage ./generic.nix {
  pname = "liboqs";
  inherit (sources.liboqs-unstable) version src;
})
