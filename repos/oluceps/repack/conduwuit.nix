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
      address = [ "0.0.0.0" ];
      # allow_registration = true;
      turn_uris = [
        "turn:nodens.nyaw.xyz?transport=udp"
        "turn:nodens.nyaw.xyz?transport=tcp"
      ];
    };
  };
}
