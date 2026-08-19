# Fetch the nvfetcher-pinned gomod2nix source at evaluation time to avoid import-from-derivation.
let
  pin = (builtins.fromJSON (builtins.readFile ../_sources/generated.json)).gomod2nix.src;
in
  builtins.fetchTree {
    type = "github";
    inherit (pin) owner repo rev;
    narHash = pin.sha256;
  }
