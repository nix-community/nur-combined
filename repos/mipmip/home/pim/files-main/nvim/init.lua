vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require("vim-options")
require("lazy").setup("plugins")

local function reloadHomeManagerNeoVimConf()
  local job = vim.fn.jobstart(
  'home-manager switch --impure --flake .#pim@lego1', 
  {
    cwd = '/etc/nixos',
    on_exit = function()
      print("home manager rebuild finished")
    end,
    on_stdout = function()
    end,
    on_stderr = function()
    end
  }
  )
end
vim.api.nvim_create_user_command('ReloadHomeManagerNeoVimConf', reloadHomeManagerNeoVimConf, {})



