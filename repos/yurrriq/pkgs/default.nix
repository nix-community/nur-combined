{ lib, pkgs, }:

let

  _nixpkgs = lib.pinnedNixpkgs {
    rev = "7f06f36ffb00e7d9206692649356f9f8c7acb2a7";
    sha256 = "1iscfzg0cyv0zm43aqs1agsbm24bg8dmjjqj4mvzk5q7r42rnrms";
  };

in

rec {

  inherit (_nixpkgs) autojump kubetail;
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

  kops = _nixpkgs.kops.overrideAttrs(oldAttrs: rec {
    name = "kops-${version}";
    version = "1.11.0";
    src = _nixpkgs.fetchFromGitHub {
      owner = "kubernetes";
      repo = "kops";
      rev = version;
      sha256 = "1z67jl66g79q6v5kjy9qxx2xp656ybv5hrc10h3wmzy0b0n30s4n";
    };
  });

  kubectl = (kubernetes.override { components = [ "cmd/kubectl" ]; }).overrideAttrs(oldAttrs: rec {
    pname = "kubectl";
    name = "${pname}-${oldAttrs.version}";
  });

  kubectx = (_nixpkgs.kubectx.override {
    inherit kubectl;
  }).overrideAttrs(oldAttrs: rec {
    version = "0.6.2";
    src = _nixpkgs.fetchFromGitHub {
      owner = "ahmetb";
      repo = oldAttrs.pname;
      rev = version;
      sha256 = "0kmzj8nmjzjfl5jgdnlizn3wmgp980xs6m9pvpplafjshx9k159c";
    };
  });

  kubernetes = _nixpkgs.kubernetes.overrideAttrs(old: rec {
    pname = "kubernetes";
    name = "${pname}-${version}";
    version = "1.11.6";
    src = _nixpkgs.fetchFromGitHub {
      owner = "kubernetes";
      repo = "kubernetes";
      rev = "v${version}";
      sha256 = "0p4kh056m84gyh05zia38aa4fqqad78ark2cycbi3nb60jj1nl9a";
    };
  });

  inherit (_nixpkgs) kubernetes-helm;

  # TODO:
  # kubernetes-helm = _nixpkgs.kubernetes-helm.overrideAttrs(oldAttrs: rec {
  #   pname = "helm";
  #   name = "${pname}-${version}";
  #   version = "2.12.2";
  #   goDeps = ./applications/networking/cluster/helm/deps.nix;
  #   src = _nixpkgs.fetchFromGitHub {
  #     owner = pname;
  #     repo = pname;
  #     rev = "v${version}";
  #     sha256 = "0a8pajj9p080f4fbylf2jixkp8xmidx2vg7k02f0prrw6q26g6gf";
  #   };
  # });

  lab = pkgs.callPackage ./applications/version-management/git-and-tools/lab {};

  noweb = pkgs.callPackage ./development/tools/literate-programming/noweb {
    inherit icon-lang;
    useIcon = true;
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
