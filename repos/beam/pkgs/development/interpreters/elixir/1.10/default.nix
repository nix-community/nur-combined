{ util, deriveElixirs }:

let
  # releases = util.findByPrefix ./. (baseNameOf ./.);
  releases = [ ./1.10.4.nix ];
in deriveElixirs releases "21" "23"
