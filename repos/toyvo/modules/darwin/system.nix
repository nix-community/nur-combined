{
  config,
  lib,
  ...
}:
{
  imports = [ ../os/users/toyvo.nix ];

  options.nixcfg.system.enable = lib.mkEnableOption "system defaults";

  config = {
    system = {
      stateVersion = 7;
      primaryUser = config.userPresets.toyvo.name;
    };
  };
}
