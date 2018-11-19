{ pkgs ? import <nixpkgs> {} }:
rec {
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

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

  chipsec = pkgs.callPackage ./pkgs/chipsec.nix {
    kernel = pkgs.linuxPackages.kernel;
    withDriver = true;
  };

  rfc-reader = pkgs.callPackage ./pkgs/rfc-reader {};

  youtube-rss = pkgs.callPackage ./pkgs/youtuberss.nix {};

  # TODO update and eventually upstream into nixpkgs
  tpm2-tools = pkgs.callPackage ./pkgs/tpm2/tpm2-tools.nix {
    inherit tpm2-tss;
  };
  tpm2-tss = pkgs.callPackage ./pkgs/tpm2/tpm2-tss.nix {};

  libdatrie = pkgs.callPackage ./pkgs/libdatrie.nix {};
  libthai = pkgs.callPackage ./pkgs/libthai.nix {
    inherit libdatrie;
  };
  thpronun = pkgs.callPackage ./pkgs/thpronun.nix {
    inherit libdatrie libthai;
  };

  # Only guaranteed to work with the packages @5da85431fb1df4fb3ac36730b2591ccc9bdf5c21
  okernel-procps-src = pkgs.procps-ng.overrideAttrs (oldAttrs: {
    patches = [];
    src = pkgs.fetchFromGitHub {
      owner ="JohnAZoidberg";
      repo = "procps";
      rev = "okernel";
      sha256 = "1iajs255zr954l0n2s4bj99kwk24ncr3cr9dq3yj9hjzy5sz9k6c";
    };
    meta.broken = true;  # Not a release - doesn't contain ./configure
  });
  okernel-procps-patch = pkgs.procps-ng.overrideAttrs (oldAttrs: {
    patches = [(pkgs.fetchpatch {
      url = "https://github.com/JohnAZoidberg/procps/commit/a5b430a50ef176c4c0223ab0060801714c16e8e8.diff";
      sha256 = "1hyi76nlhfb96mj0g8j4idf0r5wds9s027raqdji7ffa2vp71mry";
    })];
  });
  okernel-procps-package = pkgs.callPackage ./pkgs/procps-ng-okernel.nix {};

  okernel-htop = pkgs.callPackage ./pkgs/htop-okernel.nix {};

  okernel = (pkgs.callPackages ./pkgs/linux-okernel-components.nix {
    # TODO either
    #    do generic with linuxPackagesFor
    # or try to use system kernel version
    kernel = pkgs.linux_4_14;
  });
}
