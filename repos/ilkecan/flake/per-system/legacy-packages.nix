{
  self,
  ...
}:

{
  perSystem =
    { pkgs, ... }:
    {
      legacyPackages = import self { inherit pkgs; };
    };
}
