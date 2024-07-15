{ ... }@args:
let
  sane-nix-files = import ./pkgs/additional/sane-nix-files { };
in
  import "${sane-nix-files}/impure.nix" args
