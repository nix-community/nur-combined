{ callPackage ? null }:

let

  callPackage' = assert callPackage != null; callPackage;

  containerLib = callPackage' ./lib/containers { };

in

rec {

  nurPath = ./.;

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
    fzf-zsh = import ./pkgs/fzf-zsh/overlay.nix;
    fzf-nix-helpers = import ./pkgs/fzf-helpers/overlay.nix;
  };

  ### PACKAGES
  gianas-return = callPackage' ./pkgs/gianas-return { };

  glowing-bear = callPackage' ./pkgs/glowing-bear { };

  fzf-zsh = callPackage' ./pkgs/fzf-zsh { };

  fzf-nix-helpers = callPackage' ./pkgs/fzf-helpers { };

  ### LIBRARY
  mkTexDerivation = callPackage' ./lib/tex/make-tex-env.nix { };

  checkoutNixpkgs = callPackage' ./lib/release/checkout-nixpkgs.nix { };

  mkJob = callPackage' ./lib/release/mk-job.nix { };

  mkTests = callPackage' ./tests/mk-test.nix { };

  mkJobset = callPackage' ./lib/release/hydra-config.nix { };

  callNURPackage = callPackage';

  inherit (containerLib) node2container containers gen-firewall;

}
