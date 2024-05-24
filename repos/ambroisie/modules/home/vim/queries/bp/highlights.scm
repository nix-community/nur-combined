(comment) @comment

; Operators {{{
(operator) @operator

(integer_literal ("-") @operator)
; }}}

; Punctuation {{{
[
 ","
 ":"
] @punctuation.delimiter

[
 "("
 ")"
 "["
 "]"
 "{"
 "}"
] @punctuation.bracket
; }}}

; Literal {{{
(boolean_literal) @boolean

(integer_literal) @number

[
 (raw_string_literal)
 (interpreted_string_literal)
] @string

(escape_sequence) @string.escape
; }}}

; Declarations {{{
(identifier) @variable

(module
  type: (identifier) @function.call)

(module
  (property
    field: (identifier) @variable.parameter))
; }}}

; Built-ins {{{
[
 (unset)
 (default)
] @variable.builtin
(condition
 name: (identifier) @function.builtin)
; }}}

; Expressions {{{
(map_expression
  (property
    field: (identifier) @property))

(select_expression
  "select" @keyword.conditional)
; }}}

; vim: sw=2 foldmethod=marker
