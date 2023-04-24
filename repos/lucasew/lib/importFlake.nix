flake: inputs:
let
  selfWithInputs = inputs // { inherit self; };
  self = (import flake).outputs selfWithInputs;
in
self
