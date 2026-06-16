return {
  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local c = require("vscode.colors").get_colors()
      require("vscode").setup({
        style = "dark",
        transparent = true,
        italic_comments = true,
        underline_links = true,
        disable_nvimtree_bg = true,
        color_overrides = {
          vscLineNumber = "#F4D03F",
        },
        group_overrides = {
          Cursor = { fg = c.vscDarkBlue, bg = c.vscLightGreen, bold = true },
        },
      })
      vim.cmd.colorscheme("vscode")
    end,
  },

  {
    "nvimdev/dashboard-nvim",
    opts = function()
      local logo = [[
           @@@@@##
          @@@@@@.#
         @@@@@#..#
        @@@@@#...#
       @@@@@ #...#
      @@@@@  #...#
     @@@@@   #...#
     @@@@###...#@@@@
      @@@@@#........#@@
    @@@@@###########@@
 @@@@@@      @@@@@
@@@@@@       @@@@@
          ]]

      logo = string.rep("\n", 8) .. logo .. "\n\n"

      local opts = {
        theme = "doom",
        hide = {
          -- this is taken care of by lualine
          -- enabling this messes up the actual laststatus setting after loading a file
          statusline = false,
        },
        config = {
          header = vim.split(logo, "\n"),
              -- stylua: ignore
              center = {
                { action = 'lua LazyVim.pick()()',                           desc = " Find File",       icon = " ", key = "f" },
                { action = "ene | startinsert",                              desc = " New File",        icon = " ", key = "n" },
                { action = 'lua LazyVim.pick("oldfiles")()',                 desc = " Recent Files",    icon = " ", key = "r" },
                { action = 'lua LazyVim.pick("live_grep")()',                desc = " Find Text",       icon = " ", key = "g" },
                { action = 'lua LazyVim.pick.config_files()()',              desc = " Config",          icon = " ", key = "c" },
                { action = 'lua require("persistence").load()',              desc = " Restore Session", icon = " ", key = "s" },
                { action = "LazyExtras",                                     desc = " Lazy Extras",     icon = " ", key = "x" },
                { action = "Lazy",                                           desc = " Lazy",            icon = "󰒲 ", key = "l" },
                { action = function() vim.api.nvim_input("<cmd>qa<cr>") end, desc = " Quit",            icon = " ", key = "q" },
              },
          footer = function()
            local stats = require("lazy").stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
          end,
        },
      }

      for _, button in ipairs(opts.config.center) do
        button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
        button.key_format = "  %s"
      end

      -- open dashboard after closing lazy
      if vim.o.filetype == "lazy" then
        vim.api.nvim_create_autocmd("WinClosed", {
          pattern = tostring(vim.api.nvim_get_current_win()),
          once = true,
          callback = function()
            vim.schedule(function()
              vim.api.nvim_exec_autocmds("UIEnter", { group = "dashboard" })
            end)
          end,
        })
      end

      return opts
    end,
  },
}
