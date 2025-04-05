local M = {}

--- checks if a given command is executable
--- @param cmd string? command to check
--- @return boolean executable
M.is_executable = function(cmd)
    return cmd and vim.fn.executable(cmd) == 1
end

--- return a function that checks if a given command is executable
--- @param cmd string? command to check
--- @return fun(): boolean executable
M.is_executable_condition = function(cmd)
    return function()
        return M.is_executable(cmd)
    end
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

--- list all active LSP clients for specific buffer, or all buffers
--- @param bufnr int? buffer number
--- @return table all active LSP client names
M.list_lsp_clients = function(bufnr)
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    local names = {}

    for _, client in ipairs(clients) do
        table.insert(names, client.name)
    end

    return names
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
