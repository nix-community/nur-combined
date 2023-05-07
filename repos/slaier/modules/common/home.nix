{ nixosConfig, ... }:
{
  xdg.enable = true;
  home.stateVersion = nixosConfig.system.stateVersion;
}
