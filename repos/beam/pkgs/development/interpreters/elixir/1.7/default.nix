{ util, deriveElixirs }:

let
  # releases = util.findByPrefix ./. (baseNameOf ./.);
  releases = [ ./1.7.0.nix ];
in deriveElixirs releases "19" "22"
