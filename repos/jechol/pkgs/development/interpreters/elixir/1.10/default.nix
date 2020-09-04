{ deriveElixirs, mainOnly }:

let
  releases =
    if mainOnly then [ ./1.10.0.nix ] else [ ./1.10.0.nix ./1.10.4.nix ];

in deriveElixirs releases "21" "23"
