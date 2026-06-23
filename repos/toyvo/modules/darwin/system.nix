{
  config,
  lib,
  ...
}:
{
  options.nixcfg.system.enable = lib.mkEnableOption "system defaults";

  config = {
    system = {
      stateVersion = 7;
      primaryUser = config.userPresets.toyvo.name;
    };
  };
}
