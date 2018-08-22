{ pkgs ? import <nixpkgs> {} }:

{

  overlays = import ./overlays;

  pkgs = {

    browserpass = pkgs.callPackage ./pkgs/tools/security/browserpass {};

    erlang = pkgs.beam.interpreters.erlangR20.override {
      enableDebugInfo = true;
      installTargets = "install";
      wxSupport = false;
    };

    git-crypt = pkgs.callPackage ./pkgs/applications/version-management/git-and-tools/git-crypt {};

    lab = pkgs.callPackage ./pkgs/applications/version-management/git-and-tools/lab {};

    sourcetree = pkgs.callPackage ./pkgs/os-specific/darwin/sourcetree {};

    kops = pkgs.callPackage ./pkgs/applications/networking/cluster/kops {};

    kubectx = pkgs.callPackage ./pkgs/applications/networking/cluster/kubectx {};

    kubernetes = pkgs.callPackage ./pkgs/applications/networking/cluster/kubernetes {};

    kubernetes-helm = pkgs.callPackage ./pkgs/applications/networking/cluster/helm {};

    tellico = pkgs.libsForQt5.callPackage ./pkgs/applications/misc/tellico {};

  };

}
