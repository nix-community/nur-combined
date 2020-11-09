{ util, deriveElixirs }:

let
  # releases = util.findByPrefix ./. (baseNameOf ./.);
  releases = [ ./1.6.0.nix ];
in deriveElixirs releases "19" "21"
