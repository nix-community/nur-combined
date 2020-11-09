{ util, deriveElixirs }:

let
  # releases = util.findByPrefix ./. (baseNameOf ./.);
  releases = [ ./1.11.0.nix ];
in deriveElixirs releases "21" "23"
