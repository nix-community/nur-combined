{
  config,
  ...
}:

{
  flake.flakeModules = config.flake.modules.flake;
}
