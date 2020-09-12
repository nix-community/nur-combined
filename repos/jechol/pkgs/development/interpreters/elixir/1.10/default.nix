{ deriveElixirs, mainOnly }:

let
  releases = if mainOnly then [
    ./1.10.0.nix
    # We need to add 1.10.3 to use Elixir with OTP 23
    ./1.10.3.nix
  ] else [
    ./1.10.0.nix
    ./1.10.1.nix
    ./1.10.2.nix
    ./1.10.3.nix
    ./1.10.4.nix
  ];

in deriveElixirs releases "21" "23"
