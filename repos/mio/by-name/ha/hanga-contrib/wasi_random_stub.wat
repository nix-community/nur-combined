;; Kotlin/Wasm only needs random_get from preview1 in a tiny guest.
(module
  (func (export "random_get") (param i32 i32) (result i32)
    i32.const 0))
