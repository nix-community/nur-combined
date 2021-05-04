{ lib, ... }:
{
  config.my.services = {
    wireguard = {
      enable = true;
    };
  };
}
