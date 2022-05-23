lua << EOF
local wk = require("which-key")

local keys = {
    name = "Comment/uncomment",
    c = "Current line",
    u = "Uncomment the current and adjacent commented lines",
    ["gc"] = "Uncomment the current and adjacent commented lines",
}

wk.register(keys, { prefix = "gc" })
EOF
