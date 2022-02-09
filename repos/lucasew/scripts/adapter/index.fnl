(local fennel (require :fennel))

(fn get-script-file []
    (string.sub
        (. (debug.getinfo 2 :S) :source) 2))

(fn is-lua-jit [] _G.jit)

{: is-lua-jit : get-script-file :repl fennel.repl}
