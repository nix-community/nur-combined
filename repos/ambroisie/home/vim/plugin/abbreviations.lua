local abbreviations = {
    -- A few things that are hard to write in ASCII
    ["(R)"] = "©",
    ["(TM)"] = "™",
}

for text, result in pairs(abbreviations) do
    vim.cmd.abbreviate(text, result)
end
