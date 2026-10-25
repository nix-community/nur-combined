{
  pkgs ? import <nixpkgs> { },
}:
{
  atmosphere = pkgs.callPackage ./pkgs/atmosphere/package.nix { };
  citron-neo = pkgs.callPackage ./pkgs/citron-neo/package.nix { };
  hekate = pkgs.callPackage ./pkgs/hekate/package.nix { };
  nx-optimizer = pkgs.callPackage ./pkgs/nx-optimizer/package.nix { };
  panda3ds = pkgs.callPackage ./pkgs/panda3ds/package.nix { };
  pcsx2 = pkgs.callPackage ./pkgs/pcsx2/package.nix { };
  ryujinx-canary = pkgs.callPackage ./pkgs/ryujinx-canary/package.nix { };
}
