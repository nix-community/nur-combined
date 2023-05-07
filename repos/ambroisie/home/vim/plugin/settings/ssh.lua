if not require("ambroisie.utils").is_ssh() then
    return
end

local function copy(lines, _)
    require("osc52").copy(table.concat(lines, "\n"))
end

local function paste()
    return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
end

vim.g.clipboard = {
    name = "osc52",
    copy = { ["+"] = copy, ["*"] = copy },
    paste = { ["+"] = paste, ["*"] = paste },
}
