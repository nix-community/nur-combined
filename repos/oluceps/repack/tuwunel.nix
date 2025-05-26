{
  reIf,
  inputs,
  pkgs,
  ...
}:
reIf {
  systemd.services.matrix-conduit.serviceConfig = {
    ReadWritePaths = [ "/var/lib/backup/tuwunel" ];
    ExecStart = "${inputs.conduit.packages.${pkgs.system}.default}/bin/tuwunel";
    StateDirectory = "tuwunel";
  };
  services.matrix-conduit = {
    enable = true;
    settings.global = {
      server_name = "nyaw.xyz";
      port = [ 6167 ];
      address = [
        "::"
      ];
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
