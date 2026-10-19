{
  config,
  lib,
  ...
}:
{
  options.homelab.services.auth = {
    enable = lib.mkEnableOption "Auth Services";
    # auth has no systemd unit of its own -- it just enables indiko, which
    # is monitored separately as its own top-level homelab service.
    monitoredServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      internal = true;
    };
  };
  config = lib.mkIf config.homelab.services.auth.enable {
    homelab.services.indiko.enable = true;
  };

  imports = [
    ./indiko
  ];
}
