{ pkgs, ... }:

{

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;

    configure = {
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [ modus-themes-nvim ];
      };

      customRC = ''
        " Basic VimScript settings can go here
        set number
        set shiftwidth=2
        set expandtab
      '';

      customLuaRC = ''
        -- Modern Neovim Options
        vim.opt.termguicolors = true
        vim.opt.cursorline = true
        vim.opt.mouse = 'a'
        vim.opt.clipboard = 'unnamedplus'

        -- Just from ssh -> desktop, not desktop -> ssh
        -- vim.g.clipboard = 'osc52'
        -- vim.g.clipboard = {
        --   name = 'OSC 52',
        --   copy = {
        --     ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
        --     ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
        --   },
        --   paste = {
        --     ['+'] = function() return {} end,
        --     ['*'] = function() return {} end,
        --   },
        -- }

        -- Keybindings without a plugin
        vim.g.mapleader = " "
        vim.keymap.set('n', '<leader>pv', vim.cmd.Ex) -- Fast File Explorer (Netrw)

        vim.g.netrw_banner = 0
        vim.g.netrw_liststyle = 3
        vim.g.netrw_browse_split = 4

        vim.opt.path:append("**") -- Search subfolders
        vim.opt.wildignore:append("**/node_modules/*")

        require("modus-themes").setup({
          style                     = "modus_vivendi",
          variant                   = "default",
        })
        vim.cmd("colorscheme modus")
      '';
    };
  };

}
