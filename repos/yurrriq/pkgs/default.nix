{ lib, pkgs }:

let

  _nixpkgs = lib.pinnedNixpkgs (lib.fromJSONFile ../nix/nixpkgs.json);

in

rec {
  inherit (lib) buildK8sEnv;

  inherit (_nixpkgs) autojump conftest elixir_1_8 eksctl sops;

  cedille = _nixpkgs.cedille.override {
    inherit (pkgs.haskellPackages) alex happy Agda ghcWithPackages;
  };

  emacsPackages.cedille = _nixpkgs.emacsPackages.cedille.override {
    inherit cedille;
  };

  gap-pygments-lexer = pkgs.callPackage ./tools/misc/gap-pygments-lexer {
    pythonPackages = pkgs.python2Packages;
  };

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

  python35Packages = pkgs.python35Packages // {
    inherit ((lib.pinnedNixpkgs {
      rev = "97ce5d27e87af578dc964a0dba740c7531d75590";
      sha256 = "1w6j98kh6x784z5dax36pd87cxsyfi53gq67hgwwkdbnmww2q5jj";
    }).python35Packages) bugwarrior;
  };

  renderizer = pkgs.callPackage ./development/tools/renderizer {};

} // {

  cedille.meta.broken = true;

  gap-pygments-lexer.meta.broken = true;

  openlilylib-fonts.meta.broken = true;
  lilypond.meta.broken = true;
  lilypond-unstable.meta.broken = true;
  lilypond-with-fonts.meta.broken = true;

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

  onyx = (pkgs.callPackage ./os-specific/darwin/onyx {});

  skim = pkgs.callPackage ./applications/misc/skim {};

  sourcetree = pkgs.callPackage ./os-specific/darwin/sourcetree {};

  spotify = pkgs.callPackage ./applications/audio/spotify/darwin.nix {};

} // {
  onyx.meta.broken = true;
} else {

  apfs-fuse = pkgs.callPackage ./os-specific/linux/apfs-fuse {
    fuse = pkgs.fuse3;
  };

  tellico = pkgs.libsForQt5.callPackage ./applications/misc/tellico {};

} // {
  tellico.meta.broken = true;
})
