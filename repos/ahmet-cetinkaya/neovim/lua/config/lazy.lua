local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Also check for the plugin in the config directory itself (for symlinked setups)
local config_lazypath = vim.fn.stdpath("config") .. "/lazy/lazy.nvim"
if vim.fn.isdirectory(config_lazypath) == 1 then
  lazypath = config_lazypath
end

-- Bootstrap lazy.nvim
local lazy_installed = false
local lazy_lua_path = lazypath .. "/lua"

-- Check if lazy.nvim is properly installed (directory exists and has lua/init.lua)
if vim.fn.isdirectory(lazypath) == 1 then
  -- Check if the directory is not empty (has at least some files)
  local files = vim.fn.globpath(lazypath, "*", false, true)
  if #files > 0 then
    lazy_installed = true
  end
end

if not lazy_installed then
  print("lazy.nvim not found at " .. lazypath .. ", cloning from GitHub...")
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  
  -- Ensure parent directory exists
  local parent_dir = vim.fn.fnamemodify(lazypath, ":h")
  if vim.fn.isdirectory(parent_dir) ~= 1 then
    vim.fn.mkdir(parent_dir, "p")
  end
  
  -- If directory exists but is incomplete, remove it first
  if vim.fn.isdirectory(lazypath) == 1 then
    vim.fn.system({ "rm", "-rf", lazypath })
  end
  
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
  print("lazy.nvim cloned successfully!")
  lazy_installed = true
end

-- Add lazy.nvim to runtime path
vim.opt.rtp:prepend(lazypath)

-- Also ensure the lazy.nvim/lua directory is in package.path
if vim.fn.isdirectory(lazy_lua_path) == 1 then
  package.path = lazy_lua_path .. "/?.lua;" .. package.path
end

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
