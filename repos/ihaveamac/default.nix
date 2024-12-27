# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  hmModules = import ./hm-modules;

  _3dstool = pkgs.callPackage ./pkgs/3dstool { };
  lnshot = pkgs.callPackage ./pkgs/lnshot { };
  save3ds = pkgs.callPackage ./pkgs/save3ds { };
  cleaninty = pkgs.python3Packages.callPackage ./pkgs/cleaninty { };
  rvthtool = pkgs.callPackage ./pkgs/rvthtool { };
  themethod3 = pkgs.callPackage ./pkgs/themethod3 { };
  makebax = pkgs.callPackage ./pkgs/makebax { };
  ctrtool = pkgs.callPackage ./pkgs/ctrtool { };
  ctrtool-dev = pkgs.callPackage ./pkgs/ctrtool-dev { };
  makerom = pkgs.callPackage ./pkgs/makerom { };
  _3dslink = pkgs.callPackage ./pkgs/3dslink { };
  discordwikibot = pkgs.callPackage ./pkgs/discordwikibot { };
  sd-format-linux = pkgs.callPackage ./pkgs/sd-format-linux { };
  unxip = pkgs.callPackage ./pkgs/unxip { };
  corgi3ds = pkgs.libsForQt5.callPackage ./pkgs/corgi3ds { };
  ftpd = pkgs.callPackage ./pkgs/ftpd { };
  darctool = pkgs.callPackage ./pkgs/darctool { };
  bannertool = pkgs.callPackage ./pkgs/bannertool { };

  mediawiki_1_39 = pkgs.callPackage ./pkgs/mediawiki {
    version = "1.39.11";
    hash = "sha256-pEYH2AmLFTWcqZzgLrWBR9SOWHR0ruC0PNBROVV3nIo=";
  };
  mediawiki_1_40 = pkgs.callPackage ./pkgs/mediawiki {
    version = "1.40.4";
    hash = "sha256-hUkUPBFma+u4SxT1pTzxMXCwcSEbf86BjNsNoF756J4=";
    knownVulnerabilities = [ "MediaWiki 1.40 has been end-of-life since 2024-06-28." ];
  };
  mediawiki_1_41 = pkgs.callPackage ./pkgs/mediawiki {
    version = "1.41.5";
    hash = "sha256-Sq2inYfvrlP7OpQjs2lQZz4t0dU7R4EzzPNGpR83HjU=";
  };
  mediawiki_1_42 = pkgs.callPackage ./pkgs/mediawiki {
    version = "1.42.4";
    hash = "sha256-jiCXmH1Nu6fASFP2LNo338M4GeACjKSALSXzRM/o5yc=";
  };
  mediawiki_1_43 = pkgs.callPackage ./pkgs/mediawiki {
    version = "1.43.0";
    hash = "sha256-VuCn/i/3jlC5yHs9WJ8tjfW8qwAY5FSypKI5yFhr2O4=";
  };

  kwin-move-window = pkgs.callPackage ./pkgs/kwin-move-window { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...

  # compatibility
  "3dstool" = _3dstool;
  "3dslink" = _3dslink;
}
