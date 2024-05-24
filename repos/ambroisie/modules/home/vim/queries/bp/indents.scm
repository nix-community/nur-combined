; Expressions {{{
(list_expression) @indent.begin
(list_expression
  "]" @indent.branch)

(map_expression) @indent.begin
(map_expression
  "}" @indent.branch)

(select_expression) @indent.begin
(select_expression
  ")" @indent.branch)

(select_cases) @indent.begin
(select_cases
  "}" @indent.branch)
; }}}

; Declarations {{{
(module) @indent.begin
(module
  ")" @indent.branch)
(module
  "}" @indent.branch)
; }}}

; vim: sw=2 foldmethod=marker
