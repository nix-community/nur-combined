{ util, deriveElixirs, mainOnly }:

let releases = util.findByPrefix ./. (baseNameOf ./.);
in deriveElixirs releases "21" "23"
