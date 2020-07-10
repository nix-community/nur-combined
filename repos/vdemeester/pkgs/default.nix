{ sources ? import ../nix
, pkgs ? sources.pkgs { }
}:
let
  emacs27 = (pkgs.emacs.override { srcRepo = true; }).overrideAttrs (
    old: {
      name = "emacs-dev";
      version = "27.0.91";
      src = pkgs.fetchFromGitHub {
        owner = "emacs-mirror";
        repo = "emacs";
        rev = "emacs-27.0.91";
        sha256 = "0mlrg2npy1r79laahkgzhxd1qassfcdz8qk1cpw7mqgf6y5x505h";
      };
      /*
      %configure --with-dbus --with-gif --with-jpeg --with-png --with-rsvg \
           --with-tiff --with-xft --with-xpm --with-x-toolkit=gtk3 --with-gpm=no \
           --with-xwidgets --with-modules
      */
      configureFlags = old.configureFlags ++ [
        "--with-xft"
        "--with-gpm=no"
      ];
      buildInputs = old.buildInputs ++ [ pkgs.jansson ];
      patches = [
        ../overlays/patches/clean-env.patch
      ];
    }
  );
in
rec {
  # pre nur-packages import
  scripts = pkgs.callPackage ./scripts { };
  tmux-tpm = pkgs.callPackage ./tmux-tpm { };
  vrsync = pkgs.callPackage ./vrsync { };
  vde-thinkpad = pkgs.callPackage ./vde-thinkpad { };
  bus = pkgs.callPackage ../tools/bus { };

  # Mine
  ape = pkgs.callPackage ./ape { };
  fhs-std = pkgs.callPackage ./fhs/std.nix { };
  nr = pkgs.callPackage ./nr { };
  ram = pkgs.callPackage ./ram { };
  sec = pkgs.callPackage ./sec { };
  systemd-email = pkgs.callPackage ./systemd-email { };
  yak = pkgs.callPackage ./yak { };

  # emacs
  emacs = emacs27.override { inherit (pkgs) imagemagick; withXwidgets = true; };

  # Maybe upstream
  athens = pkgs.callPackage ./athens { };
  envbox = pkgs.callPackage ./envbox { };
  esc = pkgs.callPackage ./esc { };
  gogo-protobuf = pkgs.callPackage ./gogo-protobuf { };
  gorun = pkgs.callPackage ./gorun { };
  govanityurl = pkgs.callPackage ./govanityurl { };
  ko = pkgs.callPackage ./ko { };
  kss = pkgs.callPackage ./kss { };
  batzconverter = pkgs.callPackage ./batzconverter { };
  kubernix = pkgs.callPackage ./kubernix { };
  krew = pkgs.callPackage ./krew { };
  prm = pkgs.callPackage ./prm { };
  protobuild = pkgs.callPackage ./protobuild { };
  rmapi = pkgs.callPackage ./rmapi { };
  toolbox = pkgs.callPackage ./toolbox { };
  yaspell = pkgs.callPackage ./yaspell { };

  # OpenShift
  inherit (pkgs.callPackage ./oc { })
    oc_4_1
    oc_4_2
    oc_4_3
    oc_4_4
    oc_4_5
    ;
  oc = oc_4_4;
  openshift-install = pkgs.callPackage ./openshift-install { };

  inherit (pkgs.callPackage ./crc { oc_4_4 = oc_4_4; oc_4_3 = oc_4_3; })
    crc_1_9
    crc_1_10
    crc_1_11
    crc_driver_libvirt_0_12_7
    crc_driver_libvirt_0_12_8
    ;
  crc = crc_1_10;

  # Operator SDK
  inherit (pkgs.callPackage ./operator-sdk { })
    operator-sdk_0_16
    operator-sdk_0_17
    operator-sdk_0_18
    operator-sdk_0_19
    ;
  operator-sdk = operator-sdk_0_19;

  # Tekton
  inherit (pkgs.callPackage ./tkn { })
    tkn_0_8
    tkn_0_9
    tkn_0_10
    ;
  tkn = tkn_0_10;

  # Upstream
  buildkit = pkgs.callPackage ./buildkit { };
  inherit (pkgs.callPackage ./containerd { })
    containerd_1_2
    containerd_1_3
    containerd_1_4
    ;
  containerd = containerd_1_3;

  gnome-shell-extension-shell = pkgs.callPackage ./gnome/extensions/shell { };
}
