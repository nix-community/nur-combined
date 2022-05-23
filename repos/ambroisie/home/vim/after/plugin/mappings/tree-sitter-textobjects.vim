lua << EOF
local wk = require("which-key")

local motions = {
    ["]m"] = "Next method start",
    ["]M"] = "Next method end",
    ["]S"] = "Next statement start",
    ["]]"] = "Next class start",
    ["]["] = "Next class end",
    ["[m"] = "Previous method start",
    ["[M"] = "Previous method end",
    ["[S"] = "Previous statement start",
    ["[["] = "Previous class start",
    ["[]"] = "Previous class end",
}

local objects = {
    ["aa"] = "a parameter",
    ["ia"] = "inner parameter",
    ["ab"] = "a block",
    ["ib"] = "inner block",
    ["ac"] = "a class",
    ["ic"] = "inner class",
    ["af"] = "a function",
    ["if"] = "inner function",
    ["ak"] = "a comment",
    ["aS"] = "a statement",
}

wk.register(motions, { mode = "n" })
wk.register(objects, { mode = "o" })
EOF
