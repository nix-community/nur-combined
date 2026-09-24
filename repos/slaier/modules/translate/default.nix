{ config, ... }:
{
  services.libretranslate = {
    enable = true;
    threads = 8;
    extraArgs = {
      load-only = "en,zh";
    };
  };
  systemd.services.libretranslate.environment.HTTPS_PROXY = config.networking.proxy.default;
}
