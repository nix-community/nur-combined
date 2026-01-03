rec {
  # Returns a function which when applied to an argument,
  # applies the functions in the list, in the order provided.
  # `(compose [ f1 f2 f3 ]) arg` is the same as `f3 (f2 (f1 arg)`
  # `compose [ f1 f2 f3 ]` does not apply the functions, but rather
  # returns the function composition,
  # which can then be applied at a later time.
  compose = xs: (arg: builtins.foldl' (x: f: f x) arg xs);

  # Composes a list of functions (see `compose` above) and then
  # applies them to the argument.
  # `composeAndApply [ f1 f2 f3 ] arg` is the same as `f3 (f2 (f1 arg)`
  composeAndApply = xs: arg: (compose xs) arg;
}
