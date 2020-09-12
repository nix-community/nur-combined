{ deriveElixirs, mainOnly }:

let
  releases = if mainOnly then
    [ ./1.6.0.nix ]
  else [
    ./1.6.0.nix
    ./1.6.1.nix
    ./1.6.2.nix
    ./1.6.3.nix
    ./1.6.4.nix
    ./1.6.5.nix
    ./1.6.6.nix
  ];

in deriveElixirs releases "19" "21"
