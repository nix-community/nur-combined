{ config, lib, ... }:
lib.mkIf config.services.invidious.enable {
  services.invidious = {
    domain = "invidious.${config.networking.hostName}.${config.networking.domain}";
    port = 65533;
  };
}
