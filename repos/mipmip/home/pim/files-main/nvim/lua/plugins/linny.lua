return {
 'linden-project/linny.vim',
  enabled = true,
  config = function()
    vim.fn['linny#Init']()
  end,
}

