{ self }:
let
  fn = { users }:
    let inherit (self.inputs.stable.lib) recursiveUpdate;
    in builtins.foldl' (acc: user: recursiveUpdate user acc) { } users;
in fn
