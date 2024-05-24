(module
  (property
    field: (identifier) @local.definition.parameter))

(map_expression
  (property
    field: (identifier) @local.definition.field))

(assignment
  left: (identifier) @local.definition.var)

(identifier) @local.reference

; vim: sw=2 foldmethod=marker
