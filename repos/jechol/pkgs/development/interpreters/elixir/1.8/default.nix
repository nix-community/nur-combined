{ deriveElixirs, mainOnly }:

let releases = [ ./1.8.0.nix ./1.8.1.nix ./1.8.2.nix ];

in deriveElixirs releases "20" "22"
