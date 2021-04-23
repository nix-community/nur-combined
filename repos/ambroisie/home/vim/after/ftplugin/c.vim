" Create the `b:undo_ftplugin` variable if it doesn't exist
call ftplugined#check_undo_ft()

" More warnings and the usual version in flags for Clang
let b:ale_c_clang_options='-Wall -Wextra -pedantic -std=c99'
let b:undo_ftplugin.='|unlet! b:ale_c_clang_options'

" More warnings and the usual version in flags for GCC
let b:ale_c_gcc_options='-Wall -Wextra -pedantic -std=c99'
let b:undo_ftplugin.='|unlet! b:ale_c_gcc_options'

" Use compile_commands.json to look for additional flags
let b:ale_c_parse_compile_commands=1
let b:undo_ftplugin.='|unlet! b:ale_c_parse_compile_commands'
