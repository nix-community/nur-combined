{ lib, pkgs, }:

let

  _nixpkgs = lib.pinnedNixpkgs {
    rev = "6a0f0cce63b65e41ab679cc66a20f9acfc0d61c3";
    sha256 = "0dnzw8cxkx231mb2da0rfh13p0q66pic2xrgjm18izqdn5vm7qym";
  };

in

{

  inherit (_nixpkgs) autojump helmfile kops kube-prompt kubernetes-helm kubetail minikube;

  erlang = pkgs.beam.interpreters.erlangR20.override {
    enableDebugInfo = true;
    installTargets = "install";
    wxSupport = false;
  };

  gap-pygments-lexer = pkgs.callPackage ./tools/misc/gap-pygments-lexer {
    pythonPackages = pkgs.python2Packages;
  };

  git-crypt = pkgs.callPackage ./applications/version-management/git-and-tools/git-crypt {};

  kubectx = pkgs.callPackage ./applications/networking/cluster/kubectx {};

  kubernetes = pkgs.callPackage ./applications/networking/cluster/kubernetes {};

  lab = pkgs.callPackage ./applications/version-management/git-and-tools/lab {};

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
    version = "d03d8b9";
    src = pkgs.fetchFromGitHub {
      owner = "rgcr";
      repo = "m-cli";
      rev = version;
      sha512 = "39wfgp2cq6kqi7rcvxmw1hc61mcbjc1fwrb7d1s01vwrkrggn8arrzrik99qw7ymirg0aql5xc12ww3z5sfxyn7y4s1kb7v1r7kn2nm";
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

  noweb = pkgs.callPackage ./development/tools/literate-programming/noweb {
    inherit (pkgs.xorg) lndir;
  };

  tellico = pkgs.libsForQt5.callPackage ./applications/misc/tellico {};

})
