local M = {}

function M.map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

function M.get_colorscheme()
  local _t = os.date("*t").hour
  local _s = ""
  if _t >= 5 and _t < 20 then
    _s = "dawnfox"
  else
    _s = "nordfox"
  end
  return _s
end

return M
