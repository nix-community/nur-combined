{ lib, pkgs, }:

let

  _nixpkgs = lib.pinnedNixpkgs {
    rev = "ba98a7aea19cf2b56de4ff39a085b840419f9eee";
    sha256 = "0ql2zbh1ywcg824cv701ap7xk56z455vzr2zpq75skbic087lx0j";
  };

in

{

  inherit (_nixpkgs) autojump helmfile kops kubernetes-helm kubetail minikube;

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

  clementine = pkgs.callPackage ./applications/audio/clementine {};

  copyq = pkgs.callPackage ./applications/misc/copyq {};

  diff-pdf = pkgs.callPackage ./tools/text/diff-pdf {
    inherit (pkgs.darwin.apple_sdk.frameworks) Cocoa;
  };

  m-cli = pkgs.callPackage ./os-specific/darwin/m-cli {};

  inherit (_nixpkgs) musescore;

  onyx = pkgs.callPackage ./os-specific/darwin/onyx {};

  skim = pkgs.callPackage ./applications/misc/skim {};

  sourcetree = pkgs.callPackage ./os-specific/darwin/sourcetree {};

  spotify = pkgs.callPackage ./applications/audio/spotify/darwin.nix {};

} else {

  inherit (_nixpkgs) browserpass;

  tellico = pkgs.libsForQt5.callPackage ./applications/misc/tellico {};

})
