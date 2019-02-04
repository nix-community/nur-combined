{ lib, pkgs, }:

let

  _nixpkgs = lib.pinnedNixpkgs {
    rev = "f2977752c4870e881443038a71cfed1cf67f2440";
    sha256 = "0ym1vr9rll9x8h6pqdhlb5a785bysddbjzhi0syqvngx5wkap61c";
  };

in

rec {

  inherit (_nixpkgs) autojump kops kubetail;
  inherit (_nixpkgs.gitAndTools) git-crypt;

  erlang = pkgs.beam.interpreters.erlangR20.override {
    enableDebugInfo = true;
    installTargets = "install";
    wxSupport = false;
  };

  gap-pygments-lexer = pkgs.callPackage ./tools/misc/gap-pygments-lexer {
    pythonPackages = pkgs.python2Packages;
  };

  icon-lang = pkgs.callPackage ./development/interpreters/icon-lang {
    withGraphics = false;
  };

  kubectl = (kubernetes.override { components = [ "cmd/kubectl" ]; }).overrideAttrs(oldAttrs: rec {
    pname = "kubectl";
    name = "${pname}-${oldAttrs.version}";
  });

  kubernetes = _nixpkgs.kubernetes.overrideAttrs(old: rec {
    pname = "kubernetes";
    name = "${pname}-${version}";
    version = "1.11.7";
    src = _nixpkgs.fetchFromGitHub {
      owner = "kubernetes";
      repo = "kubernetes";
      rev = "v${version}";
      sha256 = "03dq9p6nwkisd80f0r3sp82vqx2ac4ja6b2s55k1l8k89snfxavf";
    };
  });

  inherit (_nixpkgs) kubernetes-helm;

  # TODO:
  # kubernetes-helm = _nixpkgs.kubernetes-helm.overrideAttrs(oldAttrs: rec {
  #   pname = "helm";
  #   name = "${pname}-${version}";
  #   version = "2.12.3";
  #   goDeps = ./applications/networking/cluster/helm/deps.nix;
  #   src = _nixpkgs.fetchFromGitHub {
  #     owner = pname;
  #     repo = pname;
  #     rev = "v${version}";
  #     sha256 = "05k1w2hqnzijwgz7b7fbq5fki6s2wdcjr5x2rr3jy5gq8iibjsfj
  #   };
  #   buildFlagsArray = ''
  #     -ldflags=-X k8s.io/helm/pkg/version.Version=v${version}
  #     -w
  #     -s
  #   '';
  # });

  lab = pkgs.callPackage ./applications/version-management/git-and-tools/lab {};

  noweb = pkgs.callPackage ./development/tools/literate-programming/noweb {
    inherit icon-lang;
    useIcon = false;
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

  inherit (_nixpkgs) musescore;

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

  tellico = pkgs.libsForQt5.callPackage ./applications/misc/tellico {};

})
