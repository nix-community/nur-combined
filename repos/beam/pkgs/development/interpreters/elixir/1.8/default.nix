{ util, deriveElixirs }:

let
  # releases = util.findByPrefix ./. (baseNameOf ./.);
  releases = [ ./1.8.0.nix ];
in deriveElixirs releases "20" "22"
