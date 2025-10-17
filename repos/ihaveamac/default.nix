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
  #tiny-wii-backup-manager = callPackage ./pkgs/tiny-wii-backup-manager { };
  twlnandtool = callPackage ./pkgs/twlnandtool { };
  roadgeek-fonts = callPackage ./pkgs/roadgeek-fonts { };

  kwin-move-window = callPackage ./pkgs/kwin-move-window { };

  mediawiki_1_39 = callPackage ./pkgs/mediawiki {
    version = "1.39.15";
    hash = "sha256-iHcTQ2PnlCvTtC7os6uOloYQHk6pk/h5X7zrvSG++rM=";
  };
  mediawiki_1_43 = callPackage ./pkgs/mediawiki {
    version = "1.43.5";
    hash = "sha256-T6USBd6Y8FTKJku9S2fewDxYQt4m+v3mAm/Ikb35UDQ=";
  };
  mediawiki_1_44 = callPackage ./pkgs/mediawiki {
    version = "1.44.2";
    hash = "sha256-59cCZpeWcfr9A3BeF6IfGFvRsoP/hD7XL+KQ6G+sQzE=";
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
