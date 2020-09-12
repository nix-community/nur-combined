{ deriveElixirs, mainOnly }:

let
  releases =
    [ ./1.10.0.nix ./1.10.1.nix ./1.10.2.nix ./1.10.3.nix ./1.10.4.nix ];

in deriveElixirs releases "21" "23"
