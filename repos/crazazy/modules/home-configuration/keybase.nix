{ config, lib, ... }:
{
  config = lib.mkIf config.privateConfig.enable {
    services.keybase.enable = true;
    services.kbfs = {
      enable = true;
      mountPoint = ".local/keybase";
    };
  };
}
