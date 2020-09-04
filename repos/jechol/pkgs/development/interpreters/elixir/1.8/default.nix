{ deriveElixirs, mainOnly }:

let
  releases = if mainOnly then [ ./1.8.0.nix ] else [ ./1.8.0.nix ./1.8.2.nix ];

in deriveElixirs releases "20" "22"
