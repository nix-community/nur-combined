{ ... }: rec {
  isFunctor = x: builtins.isAttrs x && x ? __functor;

  isCallable = x: builtins.isFunction x || isFunctor x;

  isFunctorDeep =
    x:
    builtins.isAttrs x && x ? __functor && isCallableDeep x.__functor && isCallableDeep (x.__functor x);

  isCallableDeep = x: builtins.isFunction x || isFunctorDeep x;
}
