{ inputs }:

let
  inherit (inputs) nixos-stable;

in
(final: prev: {
  release = import nixos-stable {
    system = prev.system;
    config.allowUnfree = true;
  };
})
