{ inputs }:

let
  overlays = [
    (import ./upwork-require.nix)
    (import ./sab.nix { inherit inputs; })
  ];

in overlays
