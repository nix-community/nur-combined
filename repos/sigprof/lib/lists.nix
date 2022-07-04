{...}: {
  lists = {
    # Find the index of the first element in the list matching the specified
    # predicate or return `default` if no such element exists.
    #
    # Type: findFirstIndex :: (a -> bool) -> b -> [a] -> int|b
    #
    findFirstIndex = pred: default: list: let
      op = state: value:
        if builtins.isAttrs state
        then state
        else if pred value
        then {foundIndex = state;}
        else state + 1;
      finalState = builtins.foldl' op 0 list;
    in
      finalState.foundIndex or default;
  };
}
