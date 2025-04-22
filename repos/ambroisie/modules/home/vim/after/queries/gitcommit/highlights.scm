; extends

; Highlight over-extended subject lines (rely on wrapping for message body)
((subject) @comment.error
  (#vim-match? @comment.error ".\{50,}")
  (#offset! @comment.error 0 50 0 0))
