return {
  'folke/zen-mode.nvim',
  enabled = true,

  --config = function(),
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    window = {
      backdrop = 1,
      -- height and width can be:
      -- * an absolute number of cells when > 1
      -- * a percentage of the width / height of the editor when <= 1
      -- * a function that returns the width or the height
      width = 120, -- width of the Zen window
      height = 0.9, -- height of the Zen window
      options = {
        signcolumn = "no", -- disable signcolumn
        number = false, -- disable number column
        -- relativenumber = false, -- disable relative numbers
        cursorline = false, -- disable cursorline
        cursorcolumn = false, -- disable cursor column
        foldcolumn = "0", -- disable fold column
        -- list = false, -- disable whitespace characters
      },
    },
    plugins = {
      -- disable some global vim options (vim.o...)
      -- comment the lines to not apply the options
      options = {
        enabled = true,
        ruler = false, -- disables the ruler text in the cmd line area
        showcmd = false, -- disables the command in the last line of the screen
        -- you may turn on/off statusline in zen mode by setting 'laststatus' 
        -- statusline will be shown only if 'laststatus' == 3
        laststatus = 0, -- turn off the statusline in zen mode
      },
      --twilight = { enabled = true }, -- enable to start Twilight when zen mode opens
      gitsigns = { enabled = false }, -- disables git signs
      tmux = { enabled = false }, -- disables the tmux statusline
    },
  },
}
