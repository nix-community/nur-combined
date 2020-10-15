{ util, deriveElixirs, mainOnly }:

let releases = util.findByPrefix ./. (baseNameOf ./.);
in deriveElixirs releases "18" "20"
