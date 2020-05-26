{ pkgs }:
{
  # https://github.com/NixOS/nixpkgs/pull/84117
  yuzu = pkgs.libsForQt5.callPackage ./misc/emulators/yuzu { };

  # https://github.com/NixOS/nixpkgs/pull/88821
  sm64pc = pkgs.callPackage ./games/sm64pc { };

  # https://github.com/NixOS/nixpkgs/pull/87753
  xwallpaper = pkgs.callPackage ./tools/X11/xwallpaper { };
}
