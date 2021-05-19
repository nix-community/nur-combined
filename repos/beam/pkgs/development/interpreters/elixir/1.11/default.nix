{ util, deriveElixirs }:

let
  # releases = util.findByPrefix ./. (baseNameOf ./.);
  releases = [ ./1.11.4.nix ];
in deriveElixirs releases "21" "23"
