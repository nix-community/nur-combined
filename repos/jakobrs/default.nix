{ pkgs ? import <nixpkgs> {} }:

rec {
  joycond = pkgs.callPackage ./pkgs/joycond {};

  n2n = pkgs.callPackage ./pkgs/n2n {};
  mcstatus = pkgs.python3Packages.callPackage ./pkgs/mcstatus {};

  bobrossquotes = pkgs.python3Packages.callPackage ./pkgs/bobrossquotes {};

  bsnes = pkgs.callPackage ./pkgs/bsnes {
    inherit (pkgs.qt5) qtbase wrapQtAppsHook;
  };

  avizo = pkgs.callPackage ./pkgs/avizo {};

  cpptoml = pkgs.callPackage ./pkgs/cpptoml {};
  wireplumber = pkgs.callPackage ./pkgs/wireplumber {};

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
    pname = "obs-studio";
    version = "unstable-2021-04-02";

    src = pkgs.fetchFromGitHub {
      owner = "obsproject";
      repo = "obs-studio";
      rev = "334146ee36f8751f92b54716c4ea88f4a88f453d";
      hash = "sha256:05z1azc8yy0xihvkb2dsv4j6w78q2bfbsjdwi205is2yx2h6inz2";
    };

    buildInputs = old.buildInputs ++ [ pkgs.wayland pkgs.pipewire ];
  });
}
