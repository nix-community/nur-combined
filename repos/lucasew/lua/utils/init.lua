local M = {}

function M.inspect(table, prefix, ret)
    ret = ret or {}
    prefix = prefix or "base"
    for k, v in pairs(table) do
        if type(v) == "table" then
            M.inspect(table[k], prefix.."."..k, ret)
        else
            ret[prefix.."."..k] = tostring(v)
        end
    end
    return ret
end

function M.print_elements(table, prefix, ret)
    local toShow = M.inspect(table, prefix, ret)
    for k, v in pairs(toShow) do
        print(k .. ": " .. v)
    end
end

return M
