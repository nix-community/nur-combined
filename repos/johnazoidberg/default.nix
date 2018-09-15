{ pkgs ? import <nixpkgs> {} }:
rec {
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  u-root = pkgs.callPackage ./pkgs/u-root {};

  uefi-driver-wizard = pkgs.callPackage ./pkgs/uefi-driver-wizard.nix {};

  chipsec = pkgs.callPackage ./pkgs/chipsec.nix {};

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

  # Cloc with nix support
  cloc = pkgs.cloc.overrideAttrs (oldAttrs: {
    patches = [ ./pkgs/cloc-nix.diff ];
  });

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
