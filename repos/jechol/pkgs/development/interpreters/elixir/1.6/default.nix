{ util, deriveElixirs, mainOnly }:

let releases = util.findByPrefix ./. (baseNameOf ./.);
in deriveElixirs releases "19" "21"
