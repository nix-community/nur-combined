{ inputs }:

let
  overlays = [
    # Comment when #194940 is merged
    (import ./upwork-require.nix)
    (import ./sab.nix { inherit inputs; })
  ];

in overlays
