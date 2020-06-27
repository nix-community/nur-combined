{ pkgs }:
{
  # https://github.com/NixOS/nixpkgs/pull/84117
  yuzu = pkgs.libsForQt5.callPackage ./misc/emulators/yuzu { };

  # https://github.com/NixOS/nixpkgs/pull/88821
  sm64ex = pkgs.callPackage ./games/sm64ex { };

  # https://github.com/NixOS/nixpkgs/pull/86943
  betterdiscordctl = pkgs.callPackage ./tools/misc/betterdiscordctl { };
}
