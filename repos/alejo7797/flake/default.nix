{ inputs, ... }:
{
  imports = [
    ./overlays.nix
    ./packages.nix
  ];

  systems =
    import inputs.systems
    ;
}
