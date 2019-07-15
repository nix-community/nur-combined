{ lib, pkgs }:

let

  _nixpkgs = lib.pinnedNixpkgs (lib.fromJSONFile ../nix/nixpkgs.json);

in

rec {
  inherit (lib) buildK8sEnv;

  inherit (lib.pinnedNixpkgs (lib.fromJSONFile ../nix/nixos-19.03.json)) kitty;

  inherit (_nixpkgs) autojump conftest eksctl sops;

  cedille = (_nixpkgs.cedille.override {
    inherit (pkgs.haskellPackages) alex happy Agda ghcWithPackages;
  }).overrideAttrs (_: {
    meta.broken = true;
  });

  emacsPackages.cedille = _nixpkgs.emacsPackages.cedille.override {
    inherit cedille;
  };

  inherit (_nixpkgs) elixir_1_8;

  erlang = pkgs.beam.interpreters.erlangR21.override {
    enableDebugInfo = true;
    installTargets = "install";
    wxSupport = false;
  };

  gap-pygments-lexer = (pkgs.callPackage ./tools/misc/gap-pygments-lexer {
    pythonPackages = pkgs.python2Packages;
  }).overrideAttrs (_: {
    meta.broken = true;
  });

  icon-lang = pkgs.callPackage ./development/interpreters/icon-lang {
    withGraphics = false;
  };

  kubefwd = pkgs.callPackage ./development/tools/kubefwd {};

  lab = pkgs.callPackage ./applications/version-management/git-and-tools/lab {};

  openlilylib-fonts = pkgs.callPackage ./misc/lilypond/fonts.nix { };
  lilypond = pkgs.callPackage ./misc/lilypond { guile = pkgs.guile_1_8; };
  lilypond-unstable = pkgs.callPackage ./misc/lilypond/unstable.nix {
    inherit lilypond;
  };
  lilypond-with-fonts = pkgs.callPackage ./misc/lilypond/with-fonts.nix {
    lilypond = lilypond-unstable;
  };

  noweb = pkgs.callPackage ./development/tools/literate-programming/noweb {
    inherit icon-lang;
  };

} // (if pkgs.stdenv.isDarwin then {

  chunkwm = pkgs.recurseIntoAttrs (pkgs.callPackage ./os-specific/darwin/chunkwm {
    inherit (pkgs) callPackage stdenv fetchFromGitHub imagemagick;
    inherit (pkgs.darwin.apple_sdk.frameworks) Carbon Cocoa ApplicationServices;
  });

  clementine = pkgs.callPackage ./applications/audio/clementine {};

  copyq = pkgs.callPackage ./applications/misc/copyq {};

  diff-pdf = pkgs.callPackage ./tools/text/diff-pdf {
    inherit (pkgs.darwin.apple_sdk.frameworks) Cocoa;
  };

  m-cli = pkgs.m-cli.overrideAttrs (_: rec {
    name = "m-cli-${version}";
    version = "ffdcbde2";
    src = pkgs.fetchFromGitHub {
      owner = "rgcr";
      repo = "m-cli";
      rev = version;
      sha256 = "1y7bl5i5i7da1k5yldc8fhj6jp2a33kci77kj5wmqkwpb2nkc5c2";
    };
  });

  inherit (_nixpkgs) musescore skhd;

  onyx = pkgs.callPackage ./os-specific/darwin/onyx {};

  skim = pkgs.callPackage ./applications/misc/skim {};

  sourcetree = pkgs.callPackage ./os-specific/darwin/sourcetree {};

  spotify = pkgs.callPackage ./applications/audio/spotify/darwin.nix {};

} else {

  apfs-fuse = pkgs.callPackage ./os-specific/linux/apfs-fuse {
    fuse = pkgs.fuse3;
  };

  tellico = (pkgs.libsForQt5.callPackage ./applications/misc/tellico {}).overrideAttrs (_: {
    meta.broken = true;
  });

})
