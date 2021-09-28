local lpeg = require 'lpeg'

local M = {}
M.AnyChar = lpeg.P(1)
M.Newline = lpeg.P"\n\r" + lpeg.P"\r\n" + lpeg.P"\n" + lpeg.P"\r"
M.Line = lpeg.Cg((M.AnyChar - M.Newline) ^ 1) * (M.Newline ^ 0)
M.Number = lpeg.R("09")
M.Lowercase = lpeg.R("az")
M.Uppercase = lpeg.R("AZ")
M.Letter = M.Uppercase + M.Lowercase
M.Maybe = function(pattern)
    return lpeg.P(pattern)^-1
end
function M.HandleScaping (pattern)
    return -lpeg.P"\\" * pattern
end
function M.CaptureUntil (pattern, last)
    local domain = lpeg.P(pattern) - last
    return lpeg.Cg(domain) * ((last ^ 0) - (lpeg.P"\\" * last))
end

function M.spaced(sep, first, ...)
    local args = {...}
    local ret = sep * first
    if args ~= nil then
        for _, cur in pairs(args) do
            ret = ret * sep * cur
        end
    end
    return ret * sep
end

function M.attach_debugger(grammar)
    for k, p in pairs(grammar) do
        if k == 1 then
            goto endloop
        end
        local enter = lpeg.Cmt(lpeg.P(true), function(s, p, ...)
        print("ENTER", k) return p end);
        local leave = lpeg.Cmt(lpeg.P(true), function(s, p, ...)
        print("LEAVE", k) return p end) * (lpeg.P("k") - lpeg.P "k");
        grammar[k] = lpeg.Cmt(enter * p + leave, function(s, p, ...)
        print("---", k, "---") print(p, s:sub(1, p-1)) return p end)
        ::endloop::
    end
end

return M
