local M = {}

--- checks if a given command is executable
--- @param cmd string? command to check
--- @return boolean executable
M.is_executable = function(cmd)
    return cmd and vim.fn.executable(cmd) == 1
end

--- whether or not we are currently in an SSH connection
--- @return boolean ssh connection
M.is_ssh = function()
    local variables = {
        "SSH_CONNECTION",
        "SSH_CLIENT",
        "SSH_TTY",
    }

    for _, var in ipairs(variables) do
        if string.len(os.getenv(var) or "") ~= 0 then
            return true
        end
    end

    return false
end

--- partially apply a function with given arguments
M.partial = function(f, ...)
    local a = { ... }
    local a_len = select("#", ...)

    return function(...)
        local tmp = { ... }
        local tmp_len = select("#", ...)

        -- Merge arg lists
        for i = 1, tmp_len do
            a[a_len + i] = tmp[i]
        end

        return f(unpack(a, 1, a_len + tmp_len))
    end
end

return M
