{ ... }@args:
let
  sane-nix-files = import ./pkgs/by-name/sane-nix-files/package.nix { };
in
  import "${sane-nix-files}/impure.nix" args
