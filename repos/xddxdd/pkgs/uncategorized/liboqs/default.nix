{ sources, callPackage, ... }:
(callPackage ./generic.nix { inherit (sources.liboqs) pname version src; })
