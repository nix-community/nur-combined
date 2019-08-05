{ self, ... }:
let
  package = fn: args: self.copyFunctionArgs fn (args': fn (args' // args));
in {
  inherit package;
}
