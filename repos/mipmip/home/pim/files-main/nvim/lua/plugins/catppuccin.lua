return {
  'catppuccin/nvim',
  lazy = false,
  disabled = true,
  priority = 1000,
  config = function()
    vim.o.background = 'dark' -- or 'light'
    vim.cmd.colorscheme 'catppuccin'
  end,
}
