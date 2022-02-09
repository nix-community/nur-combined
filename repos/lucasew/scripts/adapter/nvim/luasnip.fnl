(local ls (require :luasnip))
(local types (require :luasnip.util.types))

(ls.config.set_config {
  :history true
  :updateevents "TextChanged,TextChangedI"
  :enable_autosnippets true
  :ext_ops {
    types.choiceNode {
      :active {
        :virt_text [["<-" "Error"]]
      }
    }
  }
})

(when vim.keymap (do
  ; Needs nvim 0.7
  (vim.keymap.set [:i :s] "<c-k>" 
    (fn [] (when (ls.expand_or_jumpable) (ls.expand_or_jump)))
    {:silent true})

  ; Needs nvim 0.7
  (vim.keymap.set [:i :s] "<c-j>" 
    (fn [] (when (ls.jumpable -1) (ls.jump)))
    {:silent true})

  ; Needs nvim 0.7
  (vim.keymap.set [:i :s] "<c-l>" 
    (fn [] (when (ls.choice_active) (ls.change_choice 1)))
    {:silent true})
))

(tset ls.snippets :all [
  (ls.parser.parse_snippet :demo "* if this appears then it's working! *")
])

nil
