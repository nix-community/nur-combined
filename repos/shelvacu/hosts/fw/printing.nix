{ pkgs, ... }:
{
  services.printing = {
    enable = true;
    drivers = [ pkgs.cups-dymo ];
    # extraConf = ''
    #   LogLevel debug
    # '';
  };

  services.ipp-usb.enable = true;
  services.avahi = { enable = true; nssmdns4 = true; };

  hardware.sane.enable = true;
}
