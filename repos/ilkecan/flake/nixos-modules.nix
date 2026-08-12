{
  config,
  ...
}:

{
  flake.nixosModules = config.flake.modules.nixos;
}
