{ pkgs, ... }:
{
  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluez.override {
      withExperimental = true;
    };
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = "true";
      };
    };
  };
  services.blueman.enable = true;
  environment.etc = {
    "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
      bluez_monitor.properties = {
        ["bluez5.codecs"] = "[ aac ]"
      }
    '';
  };

}
