{ callPackage }:
rec {
  chump = callPackage ./chump.nix { };

  jupyterthemes = callPackage ./jupyterthemes.nix {
    inherit lesscpy;
  };

  gatt = callPackage ./gatt.nix { };

  lesscpy = callPackage ./lesscpy.nix { };

  pry = callPackage ./pry.nix { };

  priority = callPackage ./priority.nix { };
}
