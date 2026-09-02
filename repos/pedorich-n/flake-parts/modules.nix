{
  inputs,
  ...
}:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
  ];

  flake.modules.nixos = (import ../default.nix { pkgs = null; }).nixosModules;
}
