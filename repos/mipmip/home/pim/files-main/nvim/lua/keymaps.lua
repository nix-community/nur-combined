local commander = require("commander")
local telescope_builtin = require('telescope.builtin')


commander.add({
  {
    desc = "Open commander",
    cmd = require("commander").show,
    keys = { "n", "<leader>?" },
    cat = "command",
  },
  {
    desc = "Fix all whitespace",
    cmd = function()
      vim.cmd("StripWhitespace")
    end,
    keys = { "n", "<Leader>w" },
    cat = "format",
  },
  {
    desc = "Grep string under the cursor",
    cmd = function()
      telescope_builtin.grep_string()
    end,
    keys = { "n", "<c-s>" },
    cat = "telescopex",
  },
  {
    desc = "Find files in a fuzzy way",
    cmd = function()
      telescope_builtin.find_files()
    end,
    keys = { "n", ",f" },
    cat = "telescope",
  },
  {
    desc = "Grep in file tree",
    cmd = function()
      telescope_builtin.live_grep()
    end,
    keys = { "n", ",/" },
    cat = "telescope",
  },
  {
    desc = "Current buffers",
    cmd = function()
      telescope_builtin.buffers()
    end,
    keys = { "n", ",b" },
    cat = "telescope",
  },
 {
    desc = "Recent files",
    cmd = function()
      telescope_builtin.oldfiles()
    end,
    keys = { "n", ",r" },
    cat = "telescope",
  },
  {
    desc = "Toggle Checkbox",
    cmd = function()
      vim.cmd("MDTaskToggle")
    end,
    keys = { {"n", "v"}, "-" },
    cat = "markdown",
  },
  {
    desc = "Translate selection",
    cmd = function()
      vim.fn.ChatGPTTranslateSelect(vim.fn.visualmode())
    end,
    keys = { "x", "<leader>X" },
    cat = "mychatgpt",
  },
})
