{ xinomorf }:

let
  xinomorf' = import xinomorf;
  xinomorf'' = if builtins.isFunction xinomorf' then xinomorf' {} else xinomorf';
  inherit (xinomorf'') wrapper;
in wrapper
