{ pkgs ? import <nixpkgs> {} }:

rec {
  n2n = pkgs.callPackage ./pkgs/n2n {};
  mcstatus = pkgs.python3Packages.callPackage ./pkgs/mcstatus {};

  bobrossquotes = pkgs.python3Packages.callPackage ./pkgs/bobrossquotes {};

  cpptoml = pkgs.callPackage ./pkgs/cpptoml {};
  wireplumber = pkgs.callPackage ./pkgs/wireplumber { inherit cpptoml; };

  libtas = pkgs.libsForQt5.callPackage ./pkgs/libtas { multiArch = pkgs.stdenv.hostPlatform.isx86_64; };
  libtasNoMulti = pkgs.libsForQt5.callPackage ./pkgs/libtas { multiArch = false; };
  libtasMulti = pkgs.libsForQt5.callPackage ./pkgs/libtas { multiArch = true; };

  libtas-unstable = pkgs.libsForQt5.callPackage ./pkgs/libtas/unstable.nix { multiArch = pkgs.stdenv.hostPlatform.isx86_64; };
  libtasNoMulti-unstable = pkgs.libsForQt5.callPackage ./pkgs/libtas/unstable.nix { multiArch = false; };
  libtasMulti-unstable = pkgs.libsForQt5.callPackage ./pkgs/libtas/unstable.nix { multiArch = true; };

  obs-xdg-portal = pkgs.callPackage ./pkgs/obs-xdg-portal {
    inherit obs-studio;
  };

  obs-studio = pkgs.obs-studio.overrideAttrs (old: {
    pname = "obs-studio-unstable";
    version = "2021-03-11";

    src = pkgs.fetchFromGitHub {
      owner = "obsproject";
      repo = "obs-studio";
      rev = "2a87543d82a2652151d0aac29dddcd9b02b6a1fc";
      hash = "sha256:0rnv7d6fzg7i8f0bbpqjvrr099q7f8dbrd8f77db3s4nnjk4787d";
    };

    buildInputs = old.buildInputs ++ [ pkgs.wayland ];
  });
}
