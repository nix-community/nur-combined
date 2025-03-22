{
  reIf,
  inputs,
  pkgs,
  ...
}:
reIf {
  systemd.services.conduwuit.serviceConfig.ReadWritePaths = [ "/var/lib/backup/conduwuit" ];
  services.conduwuit = {
    enable = true;

    package = inputs.conduit.packages.${pkgs.system}.default;

    settings.global = {
      server_name = "nyaw.xyz";
      port = [ 6167 ];
      address = [
        "::"
      ];
      dns_tcp_fallback = false;
      ip_lookup_strategy = 5;
      database_backup_path = "/var/lib/backup/conduwuit";
      # allow_registration = true;
      turn_uris = [
        "turn:yidhra.nyaw.xyz?transport=udp"
        "turn:yidhra.nyaw.xyz?transport=tcp"
      ];
    };
  };
}
