{ deriveElixirs, mainOnly }:

let
  releases = if mainOnly then [ ./1.7.0.nix ] else [ ./1.7.0.nix ./1.7.4.nix ];

in deriveElixirs releases "19" "22"
