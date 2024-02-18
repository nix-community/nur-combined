{ config
, pkgs
, inputs
, ...
}:

let
  server_name = "nyaw.xyz";
in

{
  services.matrix-conduit = {
    enable = true;

    package = inputs.conduit.packages.${pkgs.system}.default;

    settings.global = {
      inherit server_name;
      database_backend = "rocksdb";
      port = 6167;
      address = "0.0.0.0";
      # allow_registration = true;
    };
  };
  networking.firewall =
    let inherit (config.services.matrix-conduit.settings.global) port; in {
      allowedTCPPorts = [ port ];
      allowedUDPPorts = [ port ];
    };
}

