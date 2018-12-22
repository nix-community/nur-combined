{ callPackage ? null }:

let

  callPackage' = assert callPackage != null; callPackage;

  containerLib = callPackage' ./lib/containers { };

in

rec {

  modules = {
    hydra = import ./modules/hydra.nix;
    sieve-dsl = import ./modules/sieve-dsl.nix;
    glowing-bear = import ./modules/glowing-bear.nix;
  };

  ### OVERLAYS
  overlays = {
    sudo = import ./pkgs/sudo/overlay.nix;
    termite = import ./pkgs/termite/overlay.nix;
    hydra = import ./pkgs/hydra/overlay.nix;
    php = import ./pkgs/php/overlay.nix;
    glowing-bear = import ./pkgs/glowing-bear/overlay.nix;
  };

  ### PACKAGES
  gianas-return = callPackage' ./pkgs/gianas-return { };

  glowing-bear = callPackage' ./pkgs/glowing-bear { };

  ### LIBRARY
  mkTexDerivation = callPackage' ./lib/tex/make-tex-env.nix { };

  checkoutNixpkgs = callPackage' ./lib/release/checkout-nixpkgs.nix { };

  mkJob = callPackage' ./lib/release/mk-job.nix { };

  mkTests = callPackage' ./tests/mk-test.nix { };

  callNURPackage = callPackage';

  inherit (containerLib) node2container containers gen-firewall;

}
