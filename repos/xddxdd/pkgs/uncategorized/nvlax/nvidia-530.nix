{ callPackage, ... }: callPackage ./default.nix { enableNvidia530Patch = true; }
