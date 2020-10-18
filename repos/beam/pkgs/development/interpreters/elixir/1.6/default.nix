{ util, deriveElixirs }:

let releases = util.findByPrefix ./. (baseNameOf ./.);
in deriveElixirs releases "19" "21"
