{ util, deriveElixirs }:

let
  # releases = util.findByPrefix ./. (baseNameOf ./.);
  releases = [ ./1.9.0.nix ];
in deriveElixirs releases "20" "22"
