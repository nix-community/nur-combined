{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.coredns;
in
{
  services.coredns = {
    package = pkgs.coredns.override {
      # ...
    };
    # config = ''
    # '';
  };

  networking.nameservers = lib.mkIf cfg.enable [ "127.0.0.1" ];
}
