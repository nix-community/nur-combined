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
}
