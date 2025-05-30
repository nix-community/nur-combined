{
  reIf,
  inputs,
  pkgs,
  ...
}:
reIf {
  systemd.services.tuwunel.serviceConfig = {
    ReadWritePaths = [ "/var/lib/backup/tuwunel" ];
  };
  services.tuwunel = {
    enable = true;
    settings.global = {
      server_name = "nyaw.xyz";
      port = [ 6167 ];
      address = [ "::" ];
      dns_tcp_fallback = false;
      ip_lookup_strategy = 5;
      database_backup_path = "/var/lib/backup/tuwunel";
      # allow_registration = true;
      turn_uris = [
        "turn:yidhra.nyaw.xyz?transport=udp"
        "turn:yidhra.nyaw.xyz?transport=tcp"
      ];
    };
  };
}
