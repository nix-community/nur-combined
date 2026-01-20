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

  _3dstool = callPackage ./pkgs/3dstool/package.nix { };
  lnshot = callPackage ./pkgs/lnshot/package.nix { };
  save3ds = callPackage ./pkgs/save3ds/package.nix { };
  cleaninty = python3Packages.callPackage ./pkgs/cleaninty/package.nix { };
  rvthtool = callPackage ./pkgs/rvthtool/package.nix { };
  themethod3 = callPackage ./pkgs/themethod3/package.nix { };
  makebax = callPackage ./pkgs/makebax/package.nix { };
  ctrtool = callPackage ./pkgs/ctrtool/package.nix { };
  makerom = callPackage ./pkgs/makerom/package.nix { };
  _3dslink = callPackage ./pkgs/3dslink/package.nix { };
  discordwikibot = callPackage ./pkgs/discordwikibot/package.nix { };
  sd-format-linux = callPackage ./pkgs/sd-format-linux/package.nix { };
  #unxip = callPackage ./pkgs/unxip/package.nix { };
  corgi3ds = libsForQt5.callPackage ./pkgs/corgi3ds/package.nix { };
  ftpd = callPackage ./pkgs/ftpd/package.nix { };
  darctool = callPackage ./pkgs/darctool/package.nix { };
  bannertool = callPackage ./pkgs/bannertool/package.nix { };
  wifiboot-host = callPackage ./pkgs/wifiboot-host/package.nix { };
  wfs-tools = callPackage ./pkgs/wfs-tools/package.nix { };
  kame-tools = callPackage ./pkgs/kame-tools/package.nix { };
  rstmcpp = callPackage ./pkgs/rstmcpp/package.nix { };
  kame-editor = qt6.callPackage ./pkgs/kame-editor/package.nix { inherit kame-tools rstmcpp; };
  otptool = callPackage ./pkgs/otptool/package.nix { };
  mrpack-install = callPackage ./pkgs/mrpack-install/package.nix { };
  _3dstools = callPackage ./pkgs/3dstools/package.nix { };
  cxitool = callPackage ./pkgs/cxitool/package.nix { };
  rofs-dumper = callPackage ./pkgs/rofs-dumper/package.nix { };
  _3beans = callPackage ./pkgs/3beans/package.nix { };
  local-gpss = callPackage ./pkgs/local-gpss/package.nix { };
  qcma = libsForQt5.callPackage ./pkgs/qcma/package.nix { };
  xenonrecomp = callPackage ./pkgs/xenonrecomp/package.nix { };
  darctool-yls8 = callPackage ./pkgs/darctool-yls8/package.nix { };
  ctr-gputextool = callPackage ./pkgs/ctr-gputextool/package.nix { };
  switch-tools = callPackage ./pkgs/switch-tools/package.nix { };
  ctr-logobuilder = callPackage ./pkgs/ctr-logobuilder/package.nix { };
  #tiny-wii-backup-manager = callPackage ./pkgs/tiny-wii-backup-manager/package.nix { };
  twlnandtool = callPackage ./pkgs/twlnandtool/package.nix { };
  roadgeek-fonts = callPackage ./pkgs/roadgeek-fonts/package.nix { };
  retro-aim-server = callPackage ./pkgs/retro-aim-server/package.nix { };
  rofsc = callPackage ./pkgs/rofsc/package.nix { };
  _3gxtool = callPackage ./pkgs/3gxtool/package.nix { };
  twltool = callPackage ./pkgs/twltool/package.nix { };
  tex3ds = callPackage ./pkgs/tex3ds/package.nix { };
  vanilla = callPackage ./pkgs/vanilla/package.nix { };
  caesar = callPackage ./pkgs/caesar/package.nix { };

  kwin-move-window = callPackage ./pkgs/kwin-move-window/package.nix { };

  mediawiki_1_43 = callPackage ./pkgs/mediawiki/package.nix {
    version = "1.43.6";
    hash = "sha256-S6YDacFNxGyLIa4UbD6l+LtWhXskSKEkbkRny2XKPJU=";
  };
  mediawiki_1_43_core = callPackage ./pkgs/mediawiki/package.nix {
    version = "1.43.6";
    hash = "sha256-ExHm/CWd+PY+AcgxbASdc1fL9zgvduUJjlUBEZgb3kQ=";
    core = true;
  };
  mediawiki_1_44 = callPackage ./pkgs/mediawiki/package.nix {
    version = "1.44.3";
    hash = "sha256-WBzB9+2fjjAuOOrOp0zGP/ny7V2EEvOSDn1xGDUYMv8=";
  };
  mediawiki_1_44_core = callPackage ./pkgs/mediawiki/package.nix {
    version = "1.44.3";
    hash = "sha256-nsZ483+i/oznhUnktyF7GMFil6XmLVQJzjp3llT0TWo=";
    core = true;
  };
  mediawiki_1_45 = callPackage ./pkgs/mediawiki/package.nix {
    version = "1.45.1";
    hash = "sha256-4vEmsZrsQiBRoKUODGq36QTzOzmIpHudqK+/0MCiUsw=";
  };
  mediawiki_1_45_core = callPackage ./pkgs/mediawiki/package.nix {
    version = "1.45.1";
    hash = "sha256-DVVwyY4DI22ftsjXbqawkahrht+rENR3ojHFeAt+EYs=";
    core = true;
  };

  # EOL packages
  mediawiki_1_39 = callPackage ./pkgs/mediawiki/package.nix {
    version = "1.39.17";
    hash = "sha256-LFhT0DTQw+dRYOgQQSUib6uWTX7TdzL4PnIEeB+rB7k=";
    knownVulnerabilities = [ "MediaWiki 1.39 has been end-of-life since 2025-12-31." ];
  };
  mediawiki_1_39_core = callPackage ./pkgs/mediawiki/package.nix {
    version = "1.39.17";
    hash = "sha256-CsYsjw2qCfuBvImA7H6K2bWo6b2k7yag6eBFtpo20kk=";
    core = true;
    knownVulnerabilities = [ "MediaWiki 1.39 has been end-of-life since 2025-12-31." ];
  };

  # compatibility
  "3dstool" = _3dstool;
  "3dslink" = _3dslink;
}
