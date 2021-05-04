{ config, lib, ... }:
{
  options.my.home.firefox = with lib; {
    enable = mkEnableOption "firefox configuration";

    tridactyl = {
      enable = mkOption {
        type = types.bool;
        description = "tridactyl configuration";
        example = false;
        default = config.my.home.firefox.enable;
      };
    };
  };

  imports = [
    ./firefox.nix
    ./tridactyl.nix
  ];
}
