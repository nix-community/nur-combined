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
  #unxip = callPackage ./pkgs/unxip { };
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
  retro-aim-server = callPackage ./pkgs/retro-aim-server { };
  rofsc = callPackage ./pkgs/rofsc { };
  _3gxtool = callPackage ./pkgs/3gxtool { };
  twltool = callPackage ./pkgs/twltool { };
  tex3ds = callPackage ./pkgs/tex3ds { };
  vanilla = callPackage ./pkgs/vanilla { };

  kwin-move-window = callPackage ./pkgs/kwin-move-window { };

  mediawiki_1_43 = callPackage ./pkgs/mediawiki {
    version = "1.43.6";
    hash = "sha256-S6YDacFNxGyLIa4UbD6l+LtWhXskSKEkbkRny2XKPJU=";
  };
  mediawiki_1_43_core = callPackage ./pkgs/mediawiki {
    version = "1.43.6";
    hash = "sha256-ExHm/CWd+PY+AcgxbASdc1fL9zgvduUJjlUBEZgb3kQ=";
    core = true;
  };
  mediawiki_1_44 = callPackage ./pkgs/mediawiki {
    version = "1.44.3";
    hash = "sha256-WBzB9+2fjjAuOOrOp0zGP/ny7V2EEvOSDn1xGDUYMv8=";
  };
  mediawiki_1_44_core = callPackage ./pkgs/mediawiki {
    version = "1.44.3";
    hash = "sha256-nsZ483+i/oznhUnktyF7GMFil6XmLVQJzjp3llT0TWo=";
    core = true;
  };
  mediawiki_1_45 = callPackage ./pkgs/mediawiki {
    version = "1.45.1";
    hash = "sha256-4vEmsZrsQiBRoKUODGq36QTzOzmIpHudqK+/0MCiUsw=";
  };
  mediawiki_1_45_core = callPackage ./pkgs/mediawiki {
    version = "1.45.1";
    hash = "sha256-DVVwyY4DI22ftsjXbqawkahrht+rENR3ojHFeAt+EYs=";
    core = true;
  };

  # EOL packages
  mediawiki_1_39 = callPackage ./pkgs/mediawiki {
    version = "1.39.17";
    hash = "sha256-LFhT0DTQw+dRYOgQQSUib6uWTX7TdzL4PnIEeB+rB7k=";
    knownVulnerabilities = [ "MediaWiki 1.39 has been end-of-life since 2025-12-31." ];
  };
  mediawiki_1_39_core = callPackage ./pkgs/mediawiki {
    version = "1.39.17";
    hash = "sha256-CsYsjw2qCfuBvImA7H6K2bWo6b2k7yag6eBFtpo20kk=";
    core = true;
    knownVulnerabilities = [ "MediaWiki 1.39 has been end-of-life since 2025-12-31." ];
  };

  # compatibility
  "3dstool" = _3dstool;
  "3dslink" = _3dslink;
}
