{ inputs }:

let
  overlays = [
    # Comment when #194940 is merged
    (import ./upwork-require.nix)
    (import ./sab.nix { inherit inputs; })
    (import ./shnsplit-24w.nix)
  ];

in overlays
