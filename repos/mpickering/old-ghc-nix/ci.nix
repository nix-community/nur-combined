let
  pin = import ((import ./nix/sources.nix).nixpkgs) {};
in import ./default.nix { pkgs = pin; }
