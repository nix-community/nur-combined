(local fennel (require :fennel))

(fn get-script-file []
    (string.sub
        (. (debug.getinfo 2 :S) :source) 2))

(fn is-lua-jit [] _G.jit)
(print (get-script-file))
(print (is-lua-jit))
(print "{re,}loaded")

{: is-lua-jit : get-script-file}
