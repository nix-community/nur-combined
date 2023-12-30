Mapper = require("nvim-mapper")
local telescope_builtin = require('telescope.builtin')

Mapper.map(
   "n",
   '<leader>w',
   function()
      vim.cmd("StripWhitespace")
   end,
   {silent = true},
   "Format",
   "stripwhitespace",
   "Fix all whitespace"
)

Mapper.map(
   "n",
   ',f',
   function()
      telescope_builtin.find_files()
   end,
   {silent = true, noremap = true},
   "Telescope",
   "telescope0",
   "Find files fuzzy way"
)
Mapper.map(
   "n",
   '<c-]>',
   function()
      telescope_builtin.grep_string()
   end,
   {silent = true, noremap = true},
   "Telescope",
   "telescope1",
   "Grep string under cursor in current tree"
)

Mapper.map(
   "n",
   ',/',
   function()
      telescope_builtin.live_grep()
   end,
   {silent = true, noremap = true},
   "Telescope",
   "telescope2",
   "Grep in current tree"
)

Mapper.map(
   "n",
   ',b',
   function()
      telescope_builtin.buffers()
   end,
   {silent = true, noremap = true},
   "Telescope",
   "telescope3",
   "Current Buffers"
)

Mapper.map(
   "n",
   ',h',
   function()
      telescope_builtin.help_tags()
   end,
   {silent = true, noremap = true},
   "Telescope",
   "telescope4",
   "Find help tags"
)
Mapper.map(
   "n",
   ',h',
   function()
      telescope_builtin.help_tags()
   end,
   {silent = true, noremap = true},
   "Telescope",
   "telescope5",
   "Find help tags"
)
Mapper.map(
   "n",
   '<leader>?',
   function()
      telescope_builtin.keymaps()
      --vim.cmd("Telescope mapper")
   end,
   {silent = true, noremap = true},
   "Telescope",
   "telescope6",
   "Find keymaps"
)

Mapper.map(
   "n",
   ',r',
   function()
      telescope_builtin.oldfiles()
   end,
   {silent = true, noremap = true},
   "Telescope",
   "telescope7",
   "Find recent files"
)
