return {
  -- Add indentation guides even on blank lines
  'lukas-reineke/indent-blankline.nvim',
  -- See `:help ibl`
  main = 'ibl',
  enabled = false,
  opts = {
    debounce = 100,
    indent = { char = "┊" },
    whitespace = { highlight = { "Whitespace", "NonText" } },
    scope = { exclude = { language = { "lua" } } },
  },
}


