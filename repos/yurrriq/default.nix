{ pkgs ? import <nixpkgs> {} }:

{

  modules = import ./modules;

  overlays = import ./overlays;

  pkgs = {

    autojump = pkgs.callPackage ./pkgs/tools/misc/autojump {};

    erlang = pkgs.beam.interpreters.erlangR20.override {
      enableDebugInfo = true;
      installTargets = "install";
      wxSupport = false;
    };

    gap-pygments-lexer = pkgs.callPackage ./pkgs/tools/misc/gap-pygments-lexer {
      pythonPackages = pkgs.python2Packages;
    };

    git-crypt = pkgs.callPackage ./pkgs/applications/version-management/git-and-tools/git-crypt {};

    kops = pkgs.callPackage ./pkgs/applications/networking/cluster/kops {};

    kubectx = pkgs.callPackage ./pkgs/applications/networking/cluster/kubectx {};

    kubernetes = pkgs.callPackage ./pkgs/applications/networking/cluster/kubernetes {};

    kubernetes-helm = pkgs.callPackage ./pkgs/applications/networking/cluster/helm {};

    lab = pkgs.callPackage ./pkgs/applications/version-management/git-and-tools/lab {};

  } // (if pkgs.stdenv.isDarwin then {

    clementine = pkgs.callPackage ./pkgs/applications/audio/clementine {};

    copyq = pkgs.callPackage ./pkgs/applications/misc/copyq {};

    diff-pdf = pkgs.callPackage ./pkgs/tools/text/diff-pdf {
      inherit (pkgs.darwin.apple_sdk.frameworks) Cocoa;
    };

    m-cli = pkgs.callPackage ./pkgs/os-specific/darwin/m-cli {};

    musescore = pkgs.callPackages ./pkgs/applications/audio/musescore/darwin.nix {};

    onyx = pkgs.callPackage ./pkgs/os-specific/darwin/onyx {};

    skhd = pkgs.callPackage ./pkgs/os-specific/darwin/skhd {
      inherit (pkgs.darwin.apple_sdk.frameworks) Carbon;
    };

    skim = pkgs.callPackage ./pkgs/applications/misc/skim {};

    sourcetree = pkgs.callPackage ./pkgs/os-specific/darwin/sourcetree {};

    spotify = pkgs.callPackage ./pkgs/applications/audio/spotify/darwin.nix {};

  } else {

    browserpass = pkgs.callPackage ./pkgs/tools/security/browserpass {};

    tellico = pkgs.libsForQt5.callPackage ./pkgs/applications/misc/tellico {};

  });

}
