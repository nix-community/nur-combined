# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
}:

let
  inherit (pkgs)
    callPackage
    python3Packages
    libsForQt5
    qt6
    ;
in
rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  hmModules = import ./hm-modules;

  _3dstool = callPackage ./pkgs/3dstool { };
  lnshot = callPackage ./pkgs/lnshot { };
  save3ds = callPackage ./pkgs/save3ds { };
  cleaninty = python3Packages.callPackage ./pkgs/cleaninty { };
  rvthtool = callPackage ./pkgs/rvthtool { };
  themethod3 = callPackage ./pkgs/themethod3 { };
  makebax = callPackage ./pkgs/makebax { };
  ctrtool = callPackage ./pkgs/ctrtool { };
  makerom = callPackage ./pkgs/makerom { };
  _3dslink = callPackage ./pkgs/3dslink { };
  discordwikibot = callPackage ./pkgs/discordwikibot { };
  sd-format-linux = callPackage ./pkgs/sd-format-linux { };
  unxip = callPackage ./pkgs/unxip { };
  corgi3ds = libsForQt5.callPackage ./pkgs/corgi3ds { };
  ftpd = callPackage ./pkgs/ftpd { };
  darctool = callPackage ./pkgs/darctool { };
  bannertool = callPackage ./pkgs/bannertool { };
  wifiboot-host = callPackage ./pkgs/wifiboot-host { };
  wfs-tools = callPackage ./pkgs/wfs-tools { };
  kame-tools = callPackage ./pkgs/kame-tools { };
  rstmcpp = callPackage ./pkgs/rstmcpp { };
  kame-editor = qt6.callPackage ./pkgs/kame-editor { inherit kame-tools rstmcpp; };
  otptool = callPackage ./pkgs/otptool { };
  mrpack-install = callPackage ./pkgs/mrpack-install { };
  _3dstools = callPackage ./pkgs/3dstools { };
  cxitool = callPackage ./pkgs/cxitool { };
  xiv-on-mac = callPackage ./pkgs/xiv-on-mac { };
  rofs-dumper = callPackage ./pkgs/rofs-dumper { };
  _3beans = callPackage ./pkgs/3beans { };
  local-gpss = callPackage ./pkgs/local-gpss { };
  qcma = libsForQt5.callPackage ./pkgs/qcma { };
  xenonrecomp = callPackage ./pkgs/xenonrecomp { };
  darctool-yls8 = callPackage ./pkgs/darctool-yls8 { };
  ctr-gputextool = callPackage ./pkgs/ctr-gputextool { };
  switch-tools = callPackage ./pkgs/switch-tools { };
  ctr-logobuilder = callPackage ./pkgs/ctr-logobuilder { };

  kwin-move-window = callPackage ./pkgs/kwin-move-window { };

  mediawiki_1_39 = callPackage ./pkgs/mediawiki {
    version = "1.39.13";
    hash = "sha256-u3AMCXkuzgh3GBoXTBaHOJ09/5PIpfOfgbp1Cb3r7NY=";
  };
  mediawiki_1_43 = callPackage ./pkgs/mediawiki {
    version = "1.43.3";
    hash = "sha256-5AnfQWuk2Z0nBeHrD/gWiGPbKnkcwL56h9s8E9mAGnA=";
  };
  mediawiki_1_44 = callPackage ./pkgs/mediawiki {
    version = "1.44.0";
    hash = "sha256-eSF3gIw+CDGsy+IF1XtBMzma0UHw0KglRQohskAnWI8=";
  };

  # EOL packages
  mediawiki_1_40 = callPackage ./pkgs/mediawiki {
    version = "1.40.4";
    hash = "sha256-hUkUPBFma+u4SxT1pTzxMXCwcSEbf86BjNsNoF756J4=";
    knownVulnerabilities = [ "MediaWiki 1.40 has been end-of-life since 2024-06-28." ];
  };
  mediawiki_1_41 = callPackage ./pkgs/mediawiki {
    version = "1.41.5";
    hash = "sha256-Sq2inYfvrlP7OpQjs2lQZz4t0dU7R4EzzPNGpR83HjU=";
    knownVulnerabilities = [ "MediaWiki 1.41 has been end-of-life since 2024-12-21." ];
  };
  mediawiki_1_42 = callPackage ./pkgs/mediawiki {
    version = "1.42.7";
    hash = "sha256-CmBMgUVPt6s+svV6tZcsXqRPxUkkzKCegT48T0gn2ck=";
    knownVulnerabilities = [ "MediaWiki 1.42 has been end-of-life since 2025-06-30." ];
  };

  # compatibility
  "3dstool" = _3dstool;
  "3dslink" = _3dslink;
}
