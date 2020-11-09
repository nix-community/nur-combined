{ util, deriveElixirs }:

let
  # releases = util.findByPrefix ./. (baseNameOf ./.);
  releases = [ ./1.5.0.nix ];
in deriveElixirs releases "18" "20"
