-- HACK to keep the color palette neovim uses in its embedded terminal in sync with the outer terminal.
-- should work with any terminal which supports OSC 4 protocol, known compatible with:
-- - Wezterm
if #vim.api.nvim_list_uis() == 0 then
  return
end

local pending = {}
local group = vim.api.nvim_create_augroup('terminal_palette', { clear = true })

local function component(s)
  local n = tonumber(s, 16)
  return math.floor(n * 255 / (16 ^ #s - 1) + 0.5)
end

vim.api.nvim_create_autocmd('TermResponse', {
  group = group,
  callback = function(ev)
    local i, r, g, b = ev.data.sequence:match('\027%]4;(%d+);rgb:([%x]+)/([%x]+)/([%x]+)')
    i = tonumber(i)
    if i and i >= 0 and i <= 15 then
      vim.g['terminal_color_' .. i] = string.format('#%02x%02x%02x', component(r), component(g), component(b))
      pending[i] = nil
    end
  end,
})

for i = 0, 15 do
  pending[i] = true
  vim.api.nvim_ui_send(string.format('\027]4;%d;?\027\\', i))
end
vim.wait(100, function() return next(pending) == nil end, 5)

