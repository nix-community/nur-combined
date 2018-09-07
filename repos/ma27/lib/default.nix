{ callPackage }:

let

  releaseLib = import ./release;

in

{
  ### LaTeX setup
  mkTexDerivation = callPackage ./tex/make-tex-env.nix { };

  ### Release functions for Nix and Hydra
  inherit (releaseLib) mkJob fetchNur nixpkgs;
}
