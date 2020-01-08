{ lib, pkgs, sources ? import ../nix/sources.nix }:

let

  _nixpkgs = import sources.nixpkgs-unstable {};

  _nixpkgs-stable = import sources.nixpkgs {};

in

rec {
  inherit (lib) buildK8sEnv;

  inherit (_nixpkgs-stable)
    cachix;

  inherit (_nixpkgs)
    autojump
    browserpass
    # FIXME: cachix
    conftest
    # elixir_1_8
    eksctl
    firefox
    # TODO: next
    pass
    ripgrep
    sops
    thunderbird
    tomb
    ;

  bugwarrior = _nixpkgs.python38Packages.bugwarrior;

  elba = pkgs.callPackage ./development/tools/elba {};

  gap-pygments-lexer = pkgs.callPackage ./tools/misc/gap-pygments-lexer {
    pythonPackages = pkgs.python2Packages;
  };

  icon-lang = _nixpkgs-stable.icon-lang.override {
    withGraphics = false;
  };

  lab = pkgs.callPackage ./applications/version-management/git-and-tools/lab {};

  openlilylib-fonts = pkgs.callPackage ./misc/lilypond/fonts.nix { };

  lilypond = pkgs.callPackage ./misc/lilypond { guile = pkgs.guile_1_8; };

  lilypond-unstable = pkgs.callPackage ./misc/lilypond/unstable.nix {
    inherit lilypond;
  };

  lilypond-improviso-lilyjazz = lilypond-unstable.with-fonts [
    "improviso"
    "lilyjazz"
  ];

  # FIXME: mcrl2 = pkgs.callPackage ./applications/science/logic/mcrl2 {};

  inherit (import (fetchTarball {
    url = "https://github.com/yurrriq/naal/tarball/0.2.4";
    sha256 = "0vlvi84sii6hg6g43h19qkhydip1vsh23m5iwzxpljzw55i5dgvm";
  }) {}) naal;

  noweb = _nixpkgs-stable.noweb.override {
    inherit icon-lang;
  };

  renderizer = pkgs.callPackage ./development/tools/renderizer {};

} // (import ./broken.nix { inherit pkgs; })
