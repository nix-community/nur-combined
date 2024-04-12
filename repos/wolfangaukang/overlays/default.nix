{ inputs }:

let
  overlays = [
    (import ./nixpkgs-release.nix { inherit inputs; })
    (import ./nixpkgs-unstable.nix { inherit inputs; })
  ] ++ [
    (import ./local-apps.nix)
    (import ./sab.nix { inherit inputs; })
    (import ./shnsplit-24w.nix)
  ];

in
overlays
