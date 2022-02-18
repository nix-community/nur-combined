{ pkgs, ...}:

{
  papermc-1_18_x = pkgs.callPackage ./games/papermc/1.18.nix { };
  papermc-1_17_x = pkgs.callPackage ./games/papermc/1.17.nix { };
  papermc-1_16_x = pkgs.callPackage ./games/papermc/1.16.nix { };
  papermc-1_15_x = pkgs.callPackage ./games/papermc/1.15.nix { };
  papermc-1_14_x = pkgs.callPackage ./games/papermc/1.14.nix { };
  papermc-1_13_x = pkgs.callPackage ./games/papermc/1.13.nix { };
  papermc-1_12_x = pkgs.callPackage ./games/papermc/1.12.nix { };
  papermc-1_11_x = pkgs.callPackage ./games/papermc/1.11.nix { };
  papermc-1_10_x = pkgs.callPackage ./games/papermc/1.10.nix { };

  fsharp-3 = pkgs.callPackage ./development/fsharp-3.nix { };
}
