# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
  includeIncomplete ? false,
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
  #local-gpss = callPackage ./pkgs/local-gpss/package.nix { };
  qcma = qt6.callPackage ./pkgs/qcma/package.nix { };
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
  azahar-master = callPackage ./pkgs/azahar-master/package.nix { };
  vacuumtube = callPackage ./pkgs/vacuumtube/package.nix { };
  rofs-extract = callPackage ./pkgs/rofs-extract/package.nix { };
  linux-devmgmt = qt6.callPackage ./pkgs/linux-devmgmt/package.nix { };
  rsync_341 = callPackage ./pkgs/rsync-3.4.1/default.nix { };
  rrsync_341 = callPackage ./pkgs/rsync-3.4.1/rrsync.nix { rsync = rsync_341; };
  thextech = callPackage ./pkgs/thextech/package.nix { };
  thextech-smbx = callPackage ./pkgs/thextech/smbx.nix { inherit thextech; };
  thextech-aod = callPackage ./pkgs/thextech/aod.nix { inherit thextech; };
  gmodpatchtool = callPackage ./pkgs/gmodpatchtool/package.nix { };
  yt-dlp-master = callPackage ./pkgs/yt-dlp-master/package.nix { };
  wheelwizard = callPackage ./pkgs/wheelwizard/package.nix { };
  noods = callPackage ./pkgs/noods/package.nix { };
  rokuyon = callPackage ./pkgs/rokuyon/package.nix { };

  kwin-move-window = callPackage ./pkgs/kwin-move-window/package.nix { };

  mediawiki_1_43 = callPackage ./pkgs/mediawiki/package.nix {
    version = "1.43.9";
    hash = "sha256-RZX4z9OfHEtSeOxDg2xnIFhuY5UYqnah20tVMqOVXuY=";
  };
  mediawiki_1_43_core = callPackage ./pkgs/mediawiki/package.nix {
    version = "1.43.9";
    hash = "sha256-etCk/QYgYCoYQLhmFktYMtxw2BRs2ARivP0b8Br90TE=";
    core = true;
  };
  mediawiki_1_44 = callPackage ./pkgs/mediawiki/package.nix {
    version = "1.44.6";
    hash = "sha256-KBFZrWk/ahuHzpeTGXuCe4dvWNwFCM3jjLHIq6boLFk=";
  };
  mediawiki_1_44_core = callPackage ./pkgs/mediawiki/package.nix {
    version = "1.44.6";
    hash = "sha256-qSWs/KypR5D/HcfRO5PwaJReEgB2gi20QI84k9xvbNg=";
    core = true;
  };
  mediawiki_1_45 = callPackage ./pkgs/mediawiki/package.nix {
    version = "1.45.4";
    hash = "sha256-y3yCRGjrWlEacvCOYpHQncivEuCg/9wlMu4/drsMrXw=";
  };
  mediawiki_1_45_core = callPackage ./pkgs/mediawiki/package.nix {
    version = "1.45.4";
    hash = "sha256-XHcr6fw+EOWO+6INIzWkwm0t2+8oJBuEBGReOZNlsnY=";
    core = true;
  };
  mediawiki_1_46 = callPackage ./pkgs/mediawiki/package.nix {
    version = "1.46.0";
    hash = "sha256-rDleT/07Y7hqJC79Z5JXUD5GNEW6n5ibUU2dOzQsRWo=";
  };
  mediawiki_1_46_core = callPackage ./pkgs/mediawiki/package.nix {
    version = "1.46.0";
    hash = "sha256-NMhihaXOABeQJFvAM/gWM1sJRZtjwOcOV9i6u+ASHiU=";
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
} // (if (!includeIncomplete) then {} else rec {
  aeroshell-libplasma = qt6.callPackage ./pkgs/aeroshell-libplasma/package.nix { };
  aeroshell-kwin-components = qt6.callPackage ./pkgs/aeroshell-kwin-components/package.nix {
    inherit aeroshell-libplasma;
  };
  aeroshell-smod = qt6.callPackage ./pkgs/aeroshell-smod/package.nix { };
  aeroshell-smodglow = qt6.callPackage ./pkgs/aeroshell-smod/smodglow.nix { inherit aeroshell-smod; };
  aeroshell-workspace = qt6.callPackage ./pkgs/aeroshell-workspace/package.nix {
    inherit aeroshell-libplasma;
  };
  aerothemeplasma-icons = callPackage ./pkgs/aerothemeplasma-icons/package.nix { };
  aerothemeplasma-sounds = callPackage ./pkgs/aerothemeplasma-sounds/package.nix { };
  aerothemeplasma = qt6.callPackage ./pkgs/aerothemeplasma/package.nix {
    inherit
      aeroshell-libplasma
      aeroshell-workspace
      aeroshell-kwin-components
      aerothemeplasma-sounds
      aerothemeplasma-icons
      aeroshell-smod
      aeroshell-smodglow # not sure if this is necessary
      ;
  };
})
