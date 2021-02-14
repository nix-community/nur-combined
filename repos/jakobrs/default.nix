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
    obs-studio = obs-studio-wayland;
  };

  obs-studio-wayland = pkgs.obs-studio.overrideAttrs (old: {
    pname = "obs-studio-wayland-unstable";
    version = "2021-02-02";

    src = pkgs.fetchFromGitHub {
      owner = "obsproject";
      repo = "obs-studio";
      rev = "31a9dc384dfa217b0ee54420cb977fd7f18d8cce";
      hash = "sha256:0zjdwc59nz64hy90bncbvmw7vl6gsb96b8sk894cb21gks7fayyc";
    };

    buildInputs = old.buildInputs ++ [ pkgs.wayland ];

    patches = [
      ./pkgs/obs-studio-wayland/obs.patch
    ];
  });
}
