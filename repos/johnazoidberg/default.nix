{ pkgs ? import <nixpkgs> {} }:
rec {
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  gtkterm = pkgs.callPackage ./pkgs/gtkterm { };

  dkgpg = pkgs.callPackage ./pkgs/dkgpg.nix {
    inherit libtmcg;
    bzip2 = pkgs.bzip2;
  };
  libtmcg = pkgs.callPackage ./pkgs/libtmcg.nix {};

  caas = pkgs.callPackage ./pkgs/caas.nix {
    jre = pkgs.openjdk11;
    maven = pkgs.maven.overrideAttrs (old: {
      jdk = pkgs.openjdk11;
    });
  };

  # FIXME: Doesn't really work on NixOS because it want's to write in /etc
  pppconfig = pkgs.callPackage ./pkgs/pppconfig.nix {};

  prosody-filer = pkgs.callPackage ./pkgs/prosody-filer {};

  python2Packages = pkgs.recurseIntoAttrs (
    pkgs.python2Packages.callPackage ./pkgs/python2-pkgs { }
  );

  python3Packages = pkgs.recurseIntoAttrs (
    pkgs.python3Packages.callPackage ./pkgs/python-pkgs { }
  );

  multivault = pkgs.callPackage ./pkgs/multivault.nix {
    myPython3Packages = python3Packages;
  };

  rederr = pkgs.callPackage ./pkgs/rederr.nix {};

  python-oath = pkgs.callPackage ./pkgs/python-oath.nix {};

  python-vipaccess = pkgs.python36Packages.callPackage ./pkgs/python-vipaccess.nix {
    oath = python-oath;
  };

  fbset = pkgs.callPackage ./pkgs/fbset.nix {};

  voctomix = pkgs.callPackage ./pkgs/voctomix.nix {
    inherit (pkgs.gst_all_1) gstreamer gst-plugins-bad gst-plugins-base gst-plugins-good gst-plugins-ugly;
    inherit fbset;
  };

  isabelle2018 = pkgs.callPackage ./pkgs/isabelle2018.nix {
    polyml = pkgs.polyml56;
    java = if pkgs.stdenv.isLinux then pkgs.jre else pkgs.jdk;
  };

  timg = pkgs.callPackage ./pkgs/timg.nix {};

  tiv = pkgs.callPackage ./pkgs/tiv.nix {};

  u-root = pkgs.callPackage ./pkgs/u-root {};

  uefi-driver-wizard = pkgs.callPackage ./pkgs/uefi-driver-wizard.nix {};

  linuxPackagesFor = kernel: pkgs.lib.makeExtensible (self: with self; {
    #chipsec = pkgs.callPackage ./pkgs/chipsec.nix {
    #  inherit kernel;
    #  withDriver = true;
    #};
  });
  linuxPackages_4_4 = pkgs.recurseIntoAttrs (linuxPackagesFor pkgs.linux_4_4);
  linuxPackages_4_9 = pkgs.recurseIntoAttrs (linuxPackagesFor pkgs.linux_4_9);
  linuxPackages_4_14 = pkgs.recurseIntoAttrs (linuxPackagesFor pkgs.linux_4_14);
  linuxPackages_4_19 = pkgs.recurseIntoAttrs (linuxPackagesFor pkgs.linux_4_19);
  linuxPackages_5_4 = pkgs.recurseIntoAttrs (linuxPackagesFor pkgs.linux_5_4);
  linuxPackages_5_10 = pkgs.recurseIntoAttrs (linuxPackagesFor pkgs.linux_5_10);

  rfc-reader = pkgs.callPackage ./pkgs/rfc-reader {};

  youtube-rss = pkgs.callPackage ./pkgs/youtuberss.nix {};

  thpronun = pkgs.callPackage ./pkgs/thpronun.nix {};

  uefi-firmware-parser = pkgs.uefi-firmware-parser.overrideAttrs (old: {
    prePatch = ''
      substituteInPlace setup.py --replace 'install_requires' '#install_requires'
    '';
    src = pkgs.fetchFromGitHub {
      owner = "JohnAZoidberg";
      repo = "uefi-firmware-parser";
      rev = "parse-depex-binary";
      sha256 = "sha256:1kphn2k3vv15hmv21radklg58a3a67ay9d3z4xa1iwm379f5d8gs";
    };
  });

  #################
  ##     HPE     ##
  #################
  ams = pkgs.callPackage ./pkgs/ams.nix {};
  #python-ilorest-library = pkgs.python3Packages.python-ilorest-library;
  #python-ilorest-library = pkgs.callPackage ./pkgs/python-pkgs/python-ilorest-library.nix {};
  # TODO: Build from source at https://github.com/HewlettPackard/python-redfish-utility
  ilorest = pkgs.callPackage ./pkgs/ilorest.nix {};
  hponcfg = pkgs.callPackage ./pkgs/hponcfg.nix {};
  ssacli = pkgs.callPackage ./pkgs/ssacli.nix {};
  ssa = pkgs.callPackage ./pkgs/ssa.nix {}; # TODO: Needs a service probably
  ssaducli = pkgs.callPackage ./pkgs/ssaducli.nix {};
  proliant-iso = (import <nixpkgs/nixos> {
    configuration = import ./isos/proliant.nix;
    system = "x86_64-linux";
  }).config.system.build.isoImage;
}
