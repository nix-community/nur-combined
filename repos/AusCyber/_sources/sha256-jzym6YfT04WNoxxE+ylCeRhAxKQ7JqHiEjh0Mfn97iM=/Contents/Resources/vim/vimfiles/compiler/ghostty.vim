" Vim compiler file
" Language: Ghostty config file
" Maintainer: Ghostty <https://github.com/ghostty-org/ghostty>
"
" THIS FILE IS AUTO-GENERATED

if exists("current_compiler")
  finish
endif
let current_compiler = "ghostty"

CompilerSet makeprg=ghostty\ +validate-config\ --config-file=%:S
CompilerSet errorformat=%f:%l:%m,%m
