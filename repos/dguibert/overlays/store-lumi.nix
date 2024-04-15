final: prev:
with final; let
in
  builtins.trace "lumi overlay" {
    nixStore = builtins.trace "nixStore=/users/dguibert/nix" "/users/dguibert/nix";
  }
