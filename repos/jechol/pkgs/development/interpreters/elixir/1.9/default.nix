{ deriveElixirs, mainOnly }:

let
  releases = if mainOnly then
    [ ./1.9.0.nix ]
  else [
    ./1.9.0.nix
    ./1.9.1.nix
    ./1.9.2.nix
    ./1.9.3.nix
    ./1.9.4.nix
  ];

in deriveElixirs releases "20" "22"
