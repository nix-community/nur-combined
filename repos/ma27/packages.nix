{ callPackage, moduleList, lib }:

with lib;

let

  nameFromPath = path:
    replaceStrings [ ".nix" ] [ "" ] (last (splitString "/" (toString path)));

in

rec {

  ### PACKAGES
  gianas-return = callPackage ./pkgs/gianas-return { };

  overlays = {
    sudo = import ./pkgs/sudo/overlay.nix;

    termite = import ./pkgs/termite/overlay.nix;

    hydra = import ./pkgs/hydra/overlay.nix;
  };

  ### MODULES
  modules = listToAttrs (map (path: { name = "${nameFromPath path}"; value = import path; }) (import ./module-list.nix));

  ### LIBRARY
  mkTexDerivation = callPackage ./lib/tex/make-tex-env.nix { };

  checkoutNixpkgs = import ./lib/release/checkout-nixpkgs.nix;

  mkJob = callPackage ./lib/release/mk-job.nix { };

  mkTests = callPackage ./tests/mk-test.nix { };

}
