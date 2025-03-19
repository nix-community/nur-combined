{
  reIf,
  inputs,
  pkgs,
  ...
}:
reIf {
  services.conduwuit = {
    enable = true;

    package = inputs.conduit.packages.${pkgs.system}.default;

    settings.global = {
      server_name = "nyaw.xyz";
      database_backend = "rocksdb";
      port = [ 6167 ];
      address = [
        "::"
      ];
      dns_tcp_fallback = false;
      ip_lookup_strategy = 5;
      # allow_registration = true;
      turn_uris = [
        "turn:yidhra.nyaw.xyz?transport=udp"
        "turn:yidhra.nyaw.xyz?transport=tcp"
      ];
    };
  };
}
