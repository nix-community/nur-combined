{ inputs }:

let
  inherit (inputs) nixpkgs;

in
(final: prev: {
  release = import nixpkgs {
    system = prev.system;
    config.allowUnfree = true;
  };
})
