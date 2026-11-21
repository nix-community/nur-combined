{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      devShells = {
        default = import ./_devShells/default.nix { inherit pkgs; };
      };
    };
}
