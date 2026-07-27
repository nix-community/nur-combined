{ lib, config, ... }:
{
  options.eownerdead.avahi = lib.mkEnableOption ''
    Enable avahi
  '';

  config = lib.mkIf config.eownerdead.avahi {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
      publish = {
        enable = true;
        domain = true;
        userServices = true;
        workstation = true;
      };
    };
  };
}
