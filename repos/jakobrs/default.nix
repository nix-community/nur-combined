{ pkgs ? import <nixpkgs> {} }:

rec {
  n2n = pkgs.callPackage ./pkgs/n2n {};
  mcstatus = pkgs.python3Packages.callPackage ./pkgs/mcstatus {};

  cpptoml = pkgs.callPackage ./pkgs/cpptoml {};
  wireplumber = pkgs.callPackage ./pkgs/wireplumber { inherit cpptoml; };

  libtas = pkgs.libsForQt5.callPackage ./pkgs/libtas { multiArch = pkgs.stdenv.hostPlatform.isx86_64; };
  libtasNoMulti = pkgs.libsForQt5.callPackage ./pkgs/libtas { multiArch = false; };
  libtasMulti = pkgs.libsForQt5.callPackage ./pkgs/libtas { multiArch = true; };

  libtas-unstable = pkgs.libsForQt5.callPackage ./pkgs/libtas/unstable.nix { multiArch = pkgs.stdenv.hostPlatform.isx86_64; };
  libtasNoMulti-unstable = pkgs.libsForQt5.callPackage ./pkgs/libtas/unstable.nix { multiArch = false; };
  libtasMulti-unstable = pkgs.libsForQt5.callPackage ./pkgs/libtas/unstable.nix { multiArch = true; };

  obs-xdg-portal = pkgs.callPackage ./pkgs/obs-xdg-portal {
    obs-studio = obs-studio-wayland;
  };

  obs-studio-wayland = pkgs.obs-studio.overrideAttrs (old: {
    pname = "obs-studio-wayland-unstable";
    version = "2021-01-28";

    src = pkgs.fetchFromGitHub {
      owner = "obsproject";
      repo = "obs-studio";
      rev = "1c99cad33d478b090f8228a815de32ff4c6634fe";
      sha256 = "16lyv0h9p8n8fhpmrjb2rwqh1siklvvb1hzd3s4z6aim629m9h9y";
    };

    buildInputs = old.buildInputs ++ [ pkgs.wayland ];

    patches = [
      ./pkgs/obs-studio-wayland/obs.patch
      #(pkgs.fetchpatch {
      #  url = "https://patch-diff.githubusercontent.com/raw/obsproject/obs-studio/pull/3338.patch";
      #  sha256 = "0z374pymwgyl25c6ldbd6f1hjqsl4g4mp7h9rfcpfwjmsa93z1cg";
      #})
    ];
  });
}
