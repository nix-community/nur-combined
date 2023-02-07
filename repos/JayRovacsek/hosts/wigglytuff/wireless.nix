{ config, ... }: {
  age.secrets."wireless.env" = {
    file = ../../secrets/wireless/wireless-iot.env.age;
    mode = "0400";
    symlink = false;
  };

  networking.wireless.environmentFile = config.age.secrets."wireless.env".path;

  networking.wireless = {
    enable = true;
    interfaces = [ "wlan0" ];
    networks."@IOT_SSID@".psk = "@IOT_PSK@";
  };
}
