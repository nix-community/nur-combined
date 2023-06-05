{ config, ... }:
{
  services.invidious = {
    enable = true;
    domain = "invidious.${config.networking.hostName}.${config.networking.domain}";
    port = 65533;
  };
}
