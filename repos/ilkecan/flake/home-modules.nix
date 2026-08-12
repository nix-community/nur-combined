{
  config,
  ...
}:

{
  flake.homeModules = config.flake.modules.homeManager;
}
