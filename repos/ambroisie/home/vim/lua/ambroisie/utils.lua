local M = {}

-- pretty print lua object
-- @param obj any object to pretty print
M.dump = function(obj)
    print(vim.inspect(obj))
end

--- checks if a given command is executable
---@param cmd string? command to check
---@return boolean executable
M.is_executable = function(cmd)
    return cmd and vim.fn.executable(cmd) == 1
end

--- return a function that checks if a given command is executable
---@param cmd string? command to check
---@return fun(cmd: string): boolean executable
M.is_executable_condition = function(cmd)
    return function() return M.is_executable(cmd) end
end

-- list all active LSP clients for current buffer
-- @param bufnr int? buffer number
-- @return table all active LSP client names
M.list_lsp_clients = function(bufnr)
    local clients = vim.lsp.buf_get_clients(bufnr)
    local names = {}

    for _, client in ipairs(clients) do
        table.insert(names, client.name)
    end

    return names
end

return M
