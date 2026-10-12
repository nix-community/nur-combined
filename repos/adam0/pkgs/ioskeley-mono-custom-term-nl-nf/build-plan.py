import json
import sys
from pathlib import Path

import tomllib

plans = tomllib.loads(Path(sys.argv[1]).read_text())["buildPlans"]
plan = plans["IoskeleyMono"]
term = plans["IoskeleyMonoTerm"]
for key in ("spacing", "serifs", "noCvSs", "exportGlyphNames", "metricOverride"):
    plan[key] = term[key]
plan["family"] = "Ioskeley Mono Custom Term"
plan["widths"] = {"Normal": plan["widths"]["Normal"]}
plan["variants"]["design"]["seven"] = "straight-serifless-crossbar"
plan["variants"]["design"]["at"] = "threefold"
json.dump({"buildPlans": {"IosevkaIoskeleyMonoCustomTerm": plan}}, sys.stdout)
