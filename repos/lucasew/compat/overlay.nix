let
  flake = builtins.getFlake "${builtins.toString ../.}";
in
[
  (import ../overlay.nix flake)
]
