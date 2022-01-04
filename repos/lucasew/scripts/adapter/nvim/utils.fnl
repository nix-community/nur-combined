(fn opt [key value]
  "Set a vim option"
  (tset vim.o key value))

(fn g [key value]
  "Set a vim global variable"
  (tset vim.g key value))

(fn cmd [...]
  "Run vim command"
  (vim.cmd ...))

(fn exec [...]
  "Run vimscript snippet"
  (vim.api.nvim_exec ...))

{
 : opt
 : g
 : cmd
 : exec
}
