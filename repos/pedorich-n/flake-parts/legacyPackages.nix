{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      legacyPackages = import ../default.nix { inherit pkgs; };
    };
}
