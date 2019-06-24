{ lib, pkgs }:

let

  _nixpkgs = lib.pinnedNixpkgs (lib.fromJSONFile ../nixpkgs.json);

in

rec {
  inherit (lib) buildK8sEnv;

  inherit (_nixpkgs) autojump conftest eksctl sops;
  inherit (_nixpkgs.gitAndTools) git-crypt;

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

  helmfile = pkgs.callPackage ./applications/networking/cluster/helmfile {
    buildGoModule = pkgs.buildGoModule.override {
      go = pkgs.go_1_12;
    };
  };

  icon-lang = pkgs.callPackage ./development/interpreters/icon-lang {
    withGraphics = false;
  };

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
    version = "c658afcb";
    src = pkgs.fetchFromGitHub {
      owner = "rgcr";
      repo = "m-cli";
      rev = version;
      sha256 = "1jjf4iqfkbi6jg1imcli3ajxwqpnqh7kiip4h3hc9wfwx639wljx";
    };
  });

  inherit (_nixpkgs) kitty musescore;

  onyx = pkgs.callPackage ./os-specific/darwin/onyx {};

  skhd = pkgs.skhd.overrideAttrs (_: rec {
    name = "skhd-${version}";
    version = "0.3.0";
    src = pkgs.fetchFromGitHub {
      owner = "koekeishiya";
      repo = "skhd";
      rev = "v${version}";
      sha256 = "13pqnassmzppy2ipv995rh8lzw9rraxvi0ph6zgy63cbsdfzbhgl";
    };
  });

  skim = pkgs.callPackage ./applications/misc/skim {};

  sourcetree = pkgs.callPackage ./os-specific/darwin/sourcetree {};

  spotify = pkgs.callPackage ./applications/audio/spotify/darwin.nix {};

} else {

  inherit (_nixpkgs) browserpass;

  tellico = (pkgs.libsForQt5.callPackage ./applications/misc/tellico {}).overrideAttrs (_: {
    meta.broken = true;
  });

})
